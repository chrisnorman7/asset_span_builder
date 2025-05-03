// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:asset_span_builder/asset_span_builder.dart';
import 'package:filesize/filesize.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class _AssetSpan {
  /// Create an instance.
  const _AssetSpan({
    required this.comment,
    required this.name,
    required this.assetKey,
    required this.offset,
    required this.length,
  });

  /// The comment to use.
  final String comment;

  /// The name of this span.
  final String name;

  /// The asset key.
  final String assetKey;

  /// The offset to start with.
  final int offset;

  /// The length of the span.
  final int length;
}

/// Build a data file.
Future<void> main() async {
  const filename = 'spans.yaml';
  final file = File(filename);
  if (!file.existsSync()) {
    const config = SpansConfig();
    final yaml = YamlEditor('')..update([], config.toJson());
    file.writeAsStringSync(yaml.toString());
    return print('Created empty configuration file at $filename.');
  }
  print('Loading file $filename.');
  final yaml = loadYaml(file.readAsStringSync());
  if (yaml is! YamlMap) {
    throw UnsupportedError('Error: The loaded file does not contain a map.');
  }
  final jsonSource = jsonEncode(yaml);
  final json = jsonDecode(jsonSource);
  final config = SpansConfig.fromJson(json as Map<String, dynamic>);
  for (final MapEntry(key: inputDirectoryName, value: outputFilename)
      in config.directories.entries) {
    final inputDirectory = Directory(inputDirectoryName);
    if (inputDirectory.existsSync()) {
      print('Directory: $inputDirectoryName');
      final directoryName = path.basename(inputDirectory.path);
      final dataFilename =
          '${directoryName.camelCase}${config.dataFileExtension}';
      final dataFile = File(path.join(config.dataDirectory, dataFilename));
      final dataDirectory = dataFile.parent;
      if (!dataDirectory.existsSync()) {
        print('Creating directory ${dataDirectory.path}.');
        dataDirectory.createSync(recursive: true);
      }
      if (dataFile.existsSync()) {
        dataFile.deleteSync(recursive: true);
      }
      final dataSink = dataFile.openWrite();
      final dartFile = File(outputFilename);
      if (dartFile.existsSync()) {
        dartFile.deleteSync(recursive: true);
      }
      final outputDirectory = dartFile.parent;
      if (!outputDirectory.existsSync()) {
        print('Creating Directory ${outputDirectory.path}');
        outputDirectory.createSync(recursive: true);
      }
      final assets = <_AssetSpan>[];
      var bytesWritten = 0;
      for (final file in inputDirectory.listSync().whereType<File>()) {
        final basename = path.basename(file.path);
        if (config.supportedFileExtensions.contains(
          path.extension(file.path),
        )) {
          final size = filesize(file.statSync().size);
          print('File: $basename ($size).');
          final offset = bytesWritten;
          final bytes = file.readAsBytesSync();
          dataSink.add(bytes);
          final length = bytes.length;
          bytesWritten += length;
          final assetName = path.basenameWithoutExtension(basename).camelCase;
          final assetKey = [config.dataDirectory, dataFilename].join('/');
          final comment = [directoryName, basename].join('/');
          assets.add(
            _AssetSpan(
              comment: comment,
              name: assetName,
              assetKey: assetKey,
              offset: offset,
              length: length,
            ),
          );
        } else {
          print('Skipping file $basename.');
        }
      }
      await dataSink.flush();
      await dataSink.close();
      final className = path.basenameWithoutExtension(dartFile.path).pascalCase;
      if (assets.isEmpty) {
        print('Skipping.');
        if (dataFile.existsSync()) {
          dataFile.deleteSync(recursive: true);
        }
      } else {
        final buffer =
            StringBuffer()
              ..writeln(
                "import 'package:flutter_audio_games/flutter_audio_games.dart';",
              )
              ..writeln()
              ..writeln('/// $inputDirectoryName.')
              ..writeln('abstract class $className {')
              ..writeln('  /// Stop instances from being created.')
              ..writeln('  const $className._();');
        for (final span in assets) {
          buffer
            ..writeln()
            ..writeln('  /// ${span.comment}')
            ..writeln('  static const ${span.name} = AssetSpan(')
            ..writeln("    assetKey: '${span.assetKey}',")
            ..writeln('    offset: ${span.offset},')
            ..writeln('    length: ${span.length},')
            ..writeln('  );');
        }
        buffer.writeln('}');
        dartFile.writeAsStringSync(buffer.toString());
      }
    } else {
      print('Skipping non-existant directory $inputDirectory.');
    }
  }
}

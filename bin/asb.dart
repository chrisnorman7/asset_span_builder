// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:asset_span_builder/asset_span_builder.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Build a data file.
Future<void> main() async {
  const filename = 'sounds.yaml';
  final file = File(filename);
  if (!file.existsSync()) {
    const config = SoundsConfig();
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
  final config = SoundsConfig.fromJson(json as Map<String, dynamic>);
  var bytesWritten = 0;
  for (final MapEntry(key: inputDirectoryName, value: outputFilename)
      in config.sounds.entries) {
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
      final sounds = [
        "import 'package:flutter_audio_games/flutter_audio_games.dart';\n",
      ];
      for (final file in inputDirectory.listSync().whereType<File>()) {
        final basename = path.basename(file.path);
        if (config.supportedSoundFileExtensions.contains(
          path.extension(file.path),
        )) {
          print('File: $basename.');
          final offset = bytesWritten;
          final bytes = file.readAsBytesSync();
          dataSink.add(bytes);
          final length = bytes.length;
          bytesWritten += length;
          final soundName = basename.camelCase;
          final soundPath = [config.dataDirectory, dataFilename].join('/');
          final buffer =
              StringBuffer()
                ..writeln('/// ${path.join(directoryName, basename)}')
                ..writeln('const $soundName = AssetSpan(')
                ..writeln("  assetKey: '$soundPath',")
                ..writeln('  offset: $offset,')
                ..writeln('  length: $length,')
                ..writeln(');');
          sounds.add(buffer.toString());
        } else {
          print('Skipping file $basename.');
        }
      }
      await dataSink.flush();
      await dataSink.close();
      dartFile.writeAsStringSync(sounds.join('\n'));
    } else {
      print('Skipping non-existant directory $inputDirectory.');
    }
  }
}

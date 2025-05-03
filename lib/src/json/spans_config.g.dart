// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spans_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpansConfig _$SpansConfigFromJson(Map<String, dynamic> json) => SpansConfig(
  dataDirectory: json['dataDirectory'] as String? ?? 'assets',
  directories:
      (json['directories'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {'sounds': 'lib/src/sounds.dart'},
  dataFileExtension: json['dataFileExtension'] as String? ?? '.dat',
  supportedFileExtensions:
      (json['supportedFileExtensions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['.mp3', '.wav'],
);

Map<String, dynamic> _$SpansConfigToJson(SpansConfig instance) =>
    <String, dynamic>{
      'dataDirectory': instance.dataDirectory,
      'directories': instance.directories,
      'dataFileExtension': instance.dataFileExtension,
      'supportedFileExtensions': instance.supportedFileExtensions,
    };

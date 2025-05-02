// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sounds_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SoundsConfig _$SoundsConfigFromJson(Map<String, dynamic> json) => SoundsConfig(
  dataDirectory: json['dataDirectory'] as String? ?? 'assets',
  sounds:
      (json['sounds'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {'sounds': 'lib/src/sounds.dart'},
  dataFileExtension: json['dataFileExtension'] as String? ?? '.dat',
  supportedSoundFileExtensions:
      (json['supportedSoundFileExtensions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['.mp3', '.wav'],
);

Map<String, dynamic> _$SoundsConfigToJson(SoundsConfig instance) =>
    <String, dynamic>{
      'dataDirectory': instance.dataDirectory,
      'sounds': instance.sounds,
      'dataFileExtension': instance.dataFileExtension,
      'supportedSoundFileExtensions': instance.supportedSoundFileExtensions,
    };

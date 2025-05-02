import 'package:json_annotation/json_annotation.dart';

part 'spans_config.g.dart';

/// The configuration for user-defined asset spans.
@JsonSerializable()
class SpansConfig {
  /// Create an instance.
  const SpansConfig({
    this.dataDirectory = 'assets',
    this.spans = const {'sounds': 'lib/src/sounds.dart'},
    this.dataFileExtension = '.dat',
    this.supportedSoundFileExtensions = const ['.mp3', '.wav'],
  });

  /// Create an instance from a JSON object.
  factory SpansConfig.fromJson(final Map<String, dynamic> json) =>
      _$SpansConfigFromJson(json);

  /// The name of the output directory where data files will be stored.
  final String dataDirectory;

  /// The map of directories where sounds are stored to generated dart file
  /// names.
  final Map<String, String> spans;

  /// The file extension for data files.
  final String dataFileExtension;

  /// The list of supported file extensions to be considered when loading files.
  final List<String> supportedSoundFileExtensions;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$SpansConfigToJson(this);
}

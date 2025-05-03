# asset_span_builder

## Description

A simple script for generating asset spans from data files.

## Using

Store your assets in a folder which you don't include in your flutter assets map. For example:

```shell
sounds/
  music/
    main_theme.mp3
    level_1.mp3
  voices/
    hello.wav
    goodbye.wav
    start_playing.wav
```

Run `asb` for the first time. It will generate a `spans.yaml` file which you can edit.

Add the directories you want in the `directories` map of `spans.yaml`. The resulting file should look something like this:

```yaml
dataDirectory: assets
directories:
  sounds/music: lib/src/music_sounds.dart
  sounds/voices: lib/src/voices_sounds.dart
dataFileExtension: .dat
supportedSoundFileExtensions:
  - .mp3
  - .wav
```

Run `asb` again. It should generate the above Dart files.

Now you can use the resulting spans like so:

```dart
import 'src/music_sounds.dart';
final mainTheme = MusicSounds.mainTheme.asSound(destroy: false, looping: true);
```

## Including different files

I made this package to bundle up sound files. If you have a different use case, simply edit the `supportedFileExtensions` list like so:

```yaml
supportedFileExtensions:
  - .level
  - .jpg
```

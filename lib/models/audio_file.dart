import 'dart:io';
import 'package:meta/meta.dart';
import 'timestamp.dart';

/// Model representing an audio file with metadata and associated timestamps.
class AudioFile {
  /// Full path to the audio file.
  final String path;

  /// Optional title extracted from audio metadata.
  final String? title;

  /// Duration of the audio file.
  final Duration? duration;

  /// List of timestamps associated with this audio file.
  List<Timestamp> timestamps;

  AudioFile({
    required this.path,
    this.title,
    this.duration,
    List<Timestamp>? timestamps,
  }) : timestamps = timestamps ?? [];

  /// Loads timestamps from the `.tmk` file associated with this audio file.
  ///
  /// The `.tmk` file is expected to be located in the same directory with
  /// the same base name and `.tmk` extension.
  Future<void> loadTimestamps() async {
    final tmkPath = _tmkFilePath();
    final file = File(tmkPath);

    if (!await file.exists()) {
      timestamps = [];
      return;
    }

    final lines = await file.readAsLines();
    final List<Timestamp> loaded = [];
    for (final line in lines) {
      try {
        loaded.add(Timestamp.fromTmkString(line));
      } catch (e) {
        // Ignore malformed lines or log as needed
      }
    }
    timestamps = loaded;
  }

  /// Saves the current timestamps to the associated `.tmk` file.
  Future<void> saveTimestamps() async {
    final tmkPath = _tmkFilePath();
    final file = File(tmkPath);

    final lines = timestamps.map((t) => t.toTmkString()).toList();
    await file.writeAsString(lines.join('\n'));
  }

  /// Returns the expected path for the `.tmk` file based on the audio file path.
  String _tmkFilePath() {
    final basePath = path.replaceAll(RegExp(r'\.[^.]+$'), '');
    return '$basePath.tmk';
  }
}

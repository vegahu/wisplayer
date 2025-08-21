/// Model representing a timestamp within an audio file.
///
/// Contains the exact position of the timestamp and methods to parse and serialize
/// to Philips `.tmk` format.
class Timestamp {
  /// Position of the timestamp from the start of the audio.
  final Duration position;

  Timestamp(this.position);

  /// Creates an instance from a Philips `.tmk` format string.
  ///
  /// The string must have the format '[mmmmm:ss.cc]', e.g. '[00001:21.19]'.
  /// Throws [FormatException] if the format is invalid.
  factory Timestamp.fromTmkString(String line) {
    final regex = RegExp(r'\[(\d{5}):(\d{2})\.(\d{2})\]');
    final match = regex.firstMatch(line);
    if (match == null) {
      throw FormatException('Invalid format: $line');
    }
    final minutes = int.parse(match.group(1)!);
    final seconds = int.parse(match.group(2)!);
    final centiseconds = int.parse(match.group(3)!);

    final duration = Duration(
      minutes: minutes,
      seconds: seconds,
      milliseconds: centiseconds * 10,
    );
    return Timestamp(duration);
  }

  /// Converts the timestamp to a Philips `.tmk` compatible string.
  String toTmkString() {
    final minutes = position.inMinutes;
    final seconds = position.inSeconds % 60;
    final centiseconds = (position.inMilliseconds % 1000) ~/ 10;
    final minutesStr = minutes.toString().padLeft(5, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    final centisecondsStr = centiseconds.toString().padLeft(2, '0');
    return '[$minutesStr:$secondsStr.$centisecondsStr]';
  }
}

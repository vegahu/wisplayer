import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playback_mode.dart';


class SettingsProvider with ChangeNotifier {
  static const _keyPlaybackMode = 'playback_mode';
  static const _keyPlaybackSpeed = 'playback_speed';
  static const _keyLastPosition = 'last_position';
  static const _keyLastAudioPath = 'last_audio_path';

  PlaybackMode _playbackMode = PlaybackMode.playOne;
  double _playbackSpeed = 1.0;
  Duration _lastPosition = Duration.zero;
  String? _lastAudioPath;

  PlaybackMode get playbackMode => _playbackMode;
  double get playbackSpeed => _playbackSpeed;
  Duration get lastPosition => _lastPosition;
  String? get lastAudioPath => _lastAudioPath;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_keyPlaybackMode);
    if (modeIndex != null && modeIndex >= 0 && modeIndex < PlaybackMode.values.length) {
      _playbackMode = PlaybackMode.values[modeIndex];
    }
    _playbackSpeed = prefs.getDouble(_keyPlaybackSpeed) ?? 1.0;
    final positionMilliseconds = prefs.getInt(_keyLastPosition) ?? 0;
    _lastPosition = Duration(milliseconds: positionMilliseconds);
    _lastAudioPath = prefs.getString(_keyLastAudioPath);
    notifyListeners();
  }

  Future<void> setPlaybackMode(PlaybackMode mode) async {
    _playbackMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPlaybackMode, mode.index);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyPlaybackSpeed, speed);
  }

  /// Sets last position only if the audioPath matches the current lastAudioPath.
  Future<void> setLastPosition(Duration position, String audioPath) async {
    if (audioPath != _lastAudioPath) return;
    _lastPosition = position;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastPosition, position.inMilliseconds);
  }

  /// Updates the last audio path and resets position to zero when changed.
  Future<void> setLastAudioPath(String? path) async {
    if (path != _lastAudioPath) {
      _lastPosition = Duration.zero;
    }
    _lastAudioPath = path;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_keyLastAudioPath);
      await prefs.remove(_keyLastPosition);
    } else {
      await prefs.setString(_keyLastAudioPath, path);
      await prefs.setInt(_keyLastPosition, _lastPosition.inMilliseconds);
    }
  }
}

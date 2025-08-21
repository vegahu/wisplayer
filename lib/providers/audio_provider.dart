import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_file.dart';
import '../models/timestamp.dart';
import 'settings_provider.dart';
import '../models/playback_mode.dart';


class AudioProvider with ChangeNotifier {
  final SettingsProvider settings;
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioFile? _currentAudioFile;
  Duration _position = Duration.zero;
  PlaybackMode _playbackMode = PlaybackMode.playOne;
  double _playbackSpeed = 1.0;

  AudioFile? get currentAudioFile => _currentAudioFile;
  Duration get position => _position;
  PlaybackMode get playbackMode => _playbackMode;
  double get playbackSpeed => _playbackSpeed;
  AudioPlayer get audioPlayer => _audioPlayer;

  AudioProvider({required this.settings}) {
    _audioPlayer.positionStream.listen((pos) {
      _position = pos;
      if (_currentAudioFile != null) {
        settings.setLastPosition(pos, _currentAudioFile!.path);
      }
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handlePlaybackCompleted();
      }
    });
  }

  Future<void> loadAudioFile(AudioFile audioFile) async {
    _currentAudioFile = audioFile;
    await _currentAudioFile!.loadTimestamps();

    // Load audio into player
    await _audioPlayer.setFilePath(audioFile.path);

    if (settings.lastAudioPath == _currentAudioFile!.path) {
      _position = settings.lastPosition;
      await _audioPlayer.seek(_position);
      _playbackMode = settings.playbackMode;
      _playbackSpeed = settings.playbackSpeed;
      await _audioPlayer.setSpeed(_playbackSpeed);
    } else {
      _position = Duration.zero;
      _playbackMode = PlaybackMode.playOne;
      _playbackSpeed = 1.0;
      await _audioPlayer.setSpeed(_playbackSpeed);
    }

    notifyListeners();
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero);
    updatePosition(Duration.zero);
  }

  void updatePosition(Duration newPosition) {
    _position = newPosition;
    _audioPlayer.seek(newPosition);
    settings.setLastPosition(newPosition, _currentAudioFile?.path ?? '');
    settings.setLastAudioPath(_currentAudioFile?.path);
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _audioPlayer.setSpeed(speed);
    settings.setPlaybackSpeed(speed);
    notifyListeners();
  }

  void setPlaybackMode(PlaybackMode mode) {
    _playbackMode = mode;
    settings.setPlaybackMode(mode);
    notifyListeners();
  }

  void jumpToNextTimestamp() {
    if (_currentAudioFile == null || _currentAudioFile!.timestamps.isEmpty) return;

    final timestamps = _currentAudioFile!.timestamps;
    for (var timestamp in timestamps) {
      if (timestamp.position > _position) {
        updatePosition(timestamp.position);
        break;
      }
    }
  }

  void jumpToPreviousTimestamp() {
    if (_currentAudioFile == null || _currentAudioFile!.timestamps.isEmpty) return;

    final timestamps = _currentAudioFile!.timestamps.reversed.toList();
    for (var timestamp in timestamps) {
      if (timestamp.position < _position) {
        updatePosition(timestamp.position);
        break;
      }
    }
  }

  void _handlePlaybackCompleted() {
    switch (_playbackMode) {
      case PlaybackMode.playOne:
        stop();
        break;
      case PlaybackMode.loopOne:
        updatePosition(Duration.zero);
        play();
        break;
      case PlaybackMode.loopAll:
        // Aquí debe manejarse lógica para avanzar al siguiente archivo si se implementa
        stop();
        break;
    }
  }

  Future<void> disposePlayer() async {
    await _audioPlayer.dispose();
  }
}

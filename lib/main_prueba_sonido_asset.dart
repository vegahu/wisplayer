import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String _status = 'Listo para reproducir';

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    try {
      await _player.setAsset('assets/ltp_alphabet.mp3');
      await _player.play();
      setState(() {
        _isPlaying = true;
        _status = 'Reproduciendo audio...';
      });
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
            _status = 'Reproducción terminada';
          });
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Reproducción desde Assets')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_status),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isPlaying ? null : _play,
                child: const Text('Reproducir Audio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

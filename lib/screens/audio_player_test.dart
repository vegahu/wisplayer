import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerTest extends StatefulWidget {
  const AudioPlayerTest({super.key});

  @override
  State<AudioPlayerTest> createState() => _AudioPlayerTestState();
}

class _AudioPlayerTestState extends State<AudioPlayerTest> {
  late AudioPlayer _player;
  List<FileSystemEntity> _audioFiles = [];
  bool _permissionGranted = false;
  String _message = 'Comprobando permisos...';
  String? _playingFile;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _checkPermissionAndLoadFiles();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionAndLoadFiles() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      setState(() {
        _permissionGranted = true;
        _message = 'Permiso concedido, cargando archivos...';
      });
      await _loadAudioFiles();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _message = 'Permiso denegado permanentemente. Por favor activa el permiso manualmente.';
      });
      openAppSettings();
    } else {
      setState(() {
        _message = 'Permiso denegado.';
      });
    }
  }

  Future<void> _loadAudioFiles() async {
    final dir = Directory('/sdcard/Music');
    if (!await dir.exists()) {
      setState(() {
        _message = 'Carpeta /sdcard/Music no existe.';
        _audioFiles = [];
      });
      return;
    }

    final files = await dir.list().toList();
    final audioFiles = files.where((file) {
      final ext = file.path.split('.').last.toLowerCase();
      return ['mp3', 'wav', 'ogg', 'm4a'].contains(ext);
    }).toList();

    setState(() {
      _audioFiles = audioFiles;
      _message = 'Archivos cargados: ${_audioFiles.length}';
    });
  }

  Future<void> _playFile(String path) async {
    try {
      await _player.setFilePath(path);
      await _player.play();
      setState(() {
        _playingFile = path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo reproducir el archivo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba Audio Android')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(_message),
            if (_permissionGranted && _audioFiles.isNotEmpty) ...[
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _audioFiles.length,
                  itemBuilder: (context, index) {
                    final file = _audioFiles[index];
                    final name = file.path.split('/').last;
                    final isPlaying = _playingFile == file.path;
                    return ListTile(
                      title: Text(name),
                      trailing: isPlaying
                          ? const Icon(Icons.equalizer, color: Colors.green)
                          : IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () => _playFile(file.path),
                            ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

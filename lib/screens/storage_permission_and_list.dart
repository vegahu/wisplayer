import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class StoragePermissionAudioPlayer extends StatefulWidget {
  const StoragePermissionAudioPlayer({super.key});

  @override
  State<StoragePermissionAudioPlayer> createState() => _StoragePermissionAudioPlayerState();
}

class _StoragePermissionAudioPlayerState extends State<StoragePermissionAudioPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _hasPermission = false;
  String _statusMessage = 'Verificando permisos...';
  List<FileSystemEntity> _audioFiles = [];
  String? _playingFile;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<bool> _requestPermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _checkAndRequestPermission() async {
    var status = await Permission.storage.status;
    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      setState(() {
        _statusMessage = 'Permiso permanentemente denegado';
        _hasPermission = false;
      });
      return;
    }
    if (!status.isGranted) {
      bool granted = await _requestPermission();
      if (!granted) {
        setState(() {
          _statusMessage = 'Permiso DENEGADO';
          _hasPermission = false;
        });
        return;
      }
    }
    setState(() {
      _statusMessage = 'Permiso concedido';
      _hasPermission = true;
    });
    await _listAudioFiles();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso necesario'),
        content: const Text(
          'Para listar y reproducir archivos, activa el permiso de almacenamiento manualmente en configuración.'),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Abrir Configuración'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _listAudioFiles() async {
    final dir = Directory('/sdcard/Music');
    if (!await dir.exists()) {
      setState(() {
        _statusMessage = 'Carpeta Music no encontrada en almacenamiento';
        _audioFiles = [];
      });
      return;
    }

    final files = await dir.list().toList();
    final audios = files.where((file) {
      final ext = file.path.split('.').last.toLowerCase();
      return ['mp3', 'wav', 'ogg', 'm4a'].contains(ext);
    }).toList();

    setState(() {
      _audioFiles = audios;
      _statusMessage = 'Archivos encontrados: ${audios.length}';
    });
  }

  Future<void> _playAudio(String path) async {
    try {
      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
      setState(() {
        _playingFile = path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reproduciendo audio: $e')),
      );
    }
  }

  Widget _buildList() {
    if (!_hasPermission) {
      return Center(child: Text(_statusMessage));
    }

    if (_audioFiles.isEmpty) {
      return Center(child: Text('No se encontraron archivos de audio.'));
    }

    return ListView.builder(
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
                  onPressed: () => _playAudio(file.path),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Player con Permisos')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(_statusMessage),
            const SizedBox(height: 10),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }
}

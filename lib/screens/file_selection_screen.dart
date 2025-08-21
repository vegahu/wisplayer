import 'package:flutter/material.dart';
import '../models/audio_file.dart';
import '../utils/file_loader.dart';
import '../widgets/folder_picker.dart';
import '../widgets/audio_file_list.dart';
import 'audio_player_screen.dart';

class FileSelectionScreen extends StatefulWidget {
  @override
  State<FileSelectionScreen> createState() => _FileSelectionScreenState();
}

class _FileSelectionScreenState extends State<FileSelectionScreen> {
  List<AudioFile> _audioFiles = [];
  String? _selectedFolder;

  Future<void> _loadFiles(String path) async {
    final files = await loadAudioFilesFromDirectory(path);
    setState(() {
      _audioFiles = files;
      _selectedFolder = path;
    });
  }

  void _openPlayer(AudioFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AudioPlayerScreen(audioFile: file)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Archivo'),
        actions: [FolderPicker(onFolderSelected: _loadFiles)],
      ),
      body: Column(
        children: [
          if (_selectedFolder != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Carpeta: $_selectedFolder'),
            ),
          Expanded(
            child: AudioFileList(
              audioFiles: _audioFiles,
              onFileTap: _openPlayer, // Nuevo callback
            ),
          ),
        ],
      ),
    );
  }
}

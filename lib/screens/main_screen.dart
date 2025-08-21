import 'package:flutter/material.dart';
import '../models/audio_file.dart';
import '../utils/file_loader.dart';
import '../widgets/folder_picker.dart';
import '../widgets/audio_file_list.dart';
import '../widgets/playback_controls.dart';
import '../widgets/playback_speed_selector.dart';
import '../widgets/playback_mode_selector.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<AudioFile> _audioFiles = [];
  String? _selectedFolder;

  Future<void> _loadFiles(String path) async {
    final files = await loadAudioFilesFromDirectory(path);
    setState(() {
      _audioFiles = files;
      _selectedFolder = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Player'),
        actions: [
          FolderPicker(onFolderSelected: _loadFiles),
        ],
      ),
      body: Column(
        children: [
          if (_selectedFolder != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Folder: $_selectedFolder'),
            ),
          Expanded(
            flex: 2,
            child: AudioFileList(audioFiles: _audioFiles),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlaybackControls(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Speed:'),
                    PlaybackSpeedSelector(),
                    SizedBox(width: 20),
                    Text('Mode:'),
                    PlaybackModeSelector(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

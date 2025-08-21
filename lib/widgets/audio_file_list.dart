import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audio_file.dart';
import '../providers/audio_provider.dart';

class AudioFileList extends StatelessWidget {
  final List<AudioFile> audioFiles;
  final void Function(AudioFile)? onFileTap;  // Nuevo callback opcional

  const AudioFileList({required this.audioFiles, this.onFileTap});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();

    return ListView.builder(
      itemCount: audioFiles.length,
      itemBuilder: (context, index) {
        final file = audioFiles[index];
        final isSelected = audioProvider.currentAudioFile?.path == file.path;

        return ListTile(
          title: Text(file.title ?? file.path.split('/').last),
          selected: isSelected,
          onTap: () {
            if (onFileTap != null) {
              onFileTap!(file);
            } else {
              audioProvider.loadAudioFile(file);
            }
          },
        );
      },
    );
  }
}

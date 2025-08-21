import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class PlaybackControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final isPlaying = audioProvider.audioPlayer.playing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.skip_previous),
          onPressed: audioProvider.jumpToPreviousTimestamp,
          tooltip: 'Previous Mark',
        ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            if (isPlaying) {
              audioProvider.pause();
            } else {
              audioProvider.play();
            }
          },
          tooltip: isPlaying ? 'Pause' : 'Play',
        ),
        IconButton(
          icon: Icon(Icons.stop),
          onPressed: audioProvider.stop,
          tooltip: 'Stop',
        ),
        IconButton(
          icon: Icon(Icons.skip_next),
          onPressed: audioProvider.jumpToNextTimestamp,
          tooltip: 'Next Mark',
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../models/playback_mode.dart';

class PlaybackModeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final mode = audioProvider.playbackMode;

    return DropdownButton<PlaybackMode>(
      value: mode,
      onChanged: (value) {
        if (value != null) {
          audioProvider.setPlaybackMode(value);
        }
      },
      items: PlaybackMode.values
          .map((mode) => DropdownMenuItem(
                value: mode,
                child: Text(mode.toString().split('.').last),
              ))
          .toList(),
    );
  }
}

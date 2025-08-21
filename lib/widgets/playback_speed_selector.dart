import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class PlaybackSpeedSelector extends StatelessWidget {
  final List<double> speeds = [0.5, 1.0, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final currentSpeed = audioProvider.playbackSpeed;

    return DropdownButton<double>(
      value: currentSpeed,
      onChanged: (value) {
        if (value != null) {
          audioProvider.setPlaybackSpeed(value);
        }
      },
      items: speeds
          .map((speed) => DropdownMenuItem(
                value: speed,
                child: Text('${speed}x'),
              ))
          .toList(),
    );
  }
}

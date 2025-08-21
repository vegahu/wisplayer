import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audio_file.dart';
import '../providers/audio_provider.dart';
import '../widgets/playback_speed_selector.dart';
import '../widgets/playback_mode_selector.dart';

class AudioPlayerScreen extends StatefulWidget {
  final AudioFile audioFile;

  const AudioPlayerScreen({Key? key, required this.audioFile}) : super(key: key);

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioProvider audioProvider;

  @override
  void initState() {
    super.initState();
    audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.loadAudioFile(widget.audioFile);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.audioFile.title ?? widget.audioFile.path.split('/').last;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Consumer<AudioProvider>(
                builder: (context, audioProv, child) {
                  return CircularControls(audioProvider: audioProv);
                },
              ),
            ),
          ),

          // Barra de progreso
          Consumer<AudioProvider>(
            builder: (context, audioProv, child) {
              final position = audioProv.audioPlayer.position;
              final duration = audioProv.audioPlayer.duration ?? Duration.zero;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    Slider(
                      min: 0,
                      max: duration.inMilliseconds.toDouble(),
                      value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                      onChanged: (value) {
                        audioProv.updatePosition(Duration(milliseconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position)),
                        Text(_formatDuration(duration)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: PlaybackSpeedSelector(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: PlaybackModeSelector(),
          ),
        ],
      ),
    );
  }
}

class CircularControls extends StatelessWidget {
  final AudioProvider audioProvider;

  const CircularControls({required this.audioProvider});

  @override
  Widget build(BuildContext context) {
    final isPlaying = audioProvider.audioPlayer.playing;

    final double outerDiameter = 300;
    final double centerDiameter = 120;
    final double ringRadius = outerDiameter / 2 - 50;

    final angles = [-math.pi / 2, 0, math.pi / 2, math.pi];

    final genericIcons = [Icons.circle, Icons.circle_outlined];

    void onGenericTop() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Botón genérico arriba pulsado')),
      );
    }

    void onGenericBottom() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Botón genérico abajo pulsado')),
      );
    }

    return SizedBox(
      width: outerDiameter,
      height: outerDiameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleButton(
            icon: isPlaying ? Icons.pause : Icons.play_arrow,
            size: centerDiameter,
            onPressed: () {
              if (isPlaying) {
                audioProvider.pause();
              } else {
                audioProvider.play();
              }
            },
          ),
          for (int i = 0; i < 4; i++)
            Positioned(
              left: outerDiameter / 2 + ringRadius * math.cos(angles[i]) - 30,
              top: outerDiameter / 2 + ringRadius * math.sin(angles[i]) - 30,
              child: RingButton(
                icon: i == 0
                    ? genericIcons[0] // Arriba genérico
                    : i == 1
                        ? Icons.skip_next // Derecha: salto siguiente
                        : i == 2
                            ? genericIcons[1] // Abajo genérico
                            : Icons.skip_previous, // Izquierda: salto previo
                size: 60,
                onPressed: () {
                  switch (i) {
                    case 0:
                      onGenericTop();
                      break;
                    case 1:
                      audioProvider.jumpToNextTimestamp();
                      break;
                    case 2:
                      onGenericBottom();
                      break;
                    case 3:
                      audioProvider.jumpToPreviousTimestamp();
                      break;
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class RingButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  const RingButton({
    Key? key,
    required this.icon,
    required this.size,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 3),
          ),
          child: Center(
            child: Icon(icon, size: size * 0.5, color: borderColor),
          ),
        ),
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  const CircleButton({
    Key? key,
    required this.icon,
    required this.size,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.primary;

    return Material(
      shape: CircleBorder(),
      color: bgColor,
      child: IconButton(
        iconSize: size * 0.6,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        splashRadius: size / 2,
      ),
    );
  }
}

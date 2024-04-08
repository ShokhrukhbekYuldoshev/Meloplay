import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';

class SeekBar extends StatelessWidget {
  const SeekBar({
    super.key,
    required this.player,
    this.isWhite = false,
  });

  final JustAudioPlayer player;
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.position,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        return StreamBuilder<Duration?>(
          stream: player.duration,
          builder: (context, snapshot) {
            final duration = snapshot.data ?? Duration.zero;
            return Column(
              children: [
                Slider(
                  value: position > duration
                      ? duration.inMilliseconds.toDouble()
                      : position.inMilliseconds.toDouble(),
                  min: 0,
                  max: duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    context.read<PlayerBloc>().add(
                          PlayerSeek(
                            Duration(milliseconds: value.toInt()),
                          ),
                        );
                  },
                ),

                // position and duration text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${position.inMinutes.toString().padLeft(2, '0')}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isWhite
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                    Text(
                      '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isWhite
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

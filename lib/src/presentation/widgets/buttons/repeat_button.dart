import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';

class RepeatButton extends StatelessWidget {
  const RepeatButton({super.key});

  @override
  Widget build(BuildContext context) {
    final player = sl<MusicPlayer>();
    return StreamBuilder<LoopMode>(
      stream: player.loopMode,
      builder: (context, snapshot) {
        return IconButton(
          onPressed: () {
            if (snapshot.data == LoopMode.off) {
              context.read<PlayerBloc>().add(
                    PlayerSetLoopMode(LoopMode.all),
                  );
            } else if (snapshot.data == LoopMode.all) {
              context.read<PlayerBloc>().add(
                    PlayerSetLoopMode(LoopMode.one),
                  );
            } else {
              context.read<PlayerBloc>().add(
                    PlayerSetLoopMode(LoopMode.off),
                  );
            }
          },
          icon: snapshot.data == LoopMode.off
              ? const Icon(
                  Icons.repeat_outlined,
                  color: Colors.grey,
                )
              : snapshot.data == LoopMode.all
                  ? const Icon(
                      Icons.repeat_outlined,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.repeat_one_outlined,
                      color: Colors.white,
                    ),
          iconSize: 30,
          tooltip: 'Repeat',
        );
      },
    );
  }
}

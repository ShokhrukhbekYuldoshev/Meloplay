import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/core/constants/assets.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final player = sl<MusicPlayer>();
    return StreamBuilder<bool>(
      stream: player.shuffleModeEnabled,
      builder: (context, snapshot) {
        return IconButton(
          onPressed: () async {
            context.read<PlayerBloc>().add(
                  PlayerSetShuffleModeEnabled(
                    !(snapshot.data ?? false),
                  ),
                );
          },
          icon: snapshot.data == false
              ? SvgPicture.asset(
                  Assets.shuffleSvg,
                  colorFilter: ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                )
              : SvgPicture.asset(
                  Assets.shuffleSvg,
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
          tooltip: 'Shuffle',
        );
      },
    );
  }
}

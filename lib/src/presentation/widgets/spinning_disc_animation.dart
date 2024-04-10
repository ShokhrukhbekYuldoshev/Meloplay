import 'dart:math';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';

class SpinningDisc extends StatefulWidget {
  final int id;

  const SpinningDisc({super.key, required this.id});

  @override
  State<SpinningDisc> createState() => _SpinningDiscState();
}

class _SpinningDiscState extends State<SpinningDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: sl<JustAudioPlayer>().playing,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        // if not playing, don't stop the animation
        if (!snapshot.data!) {
          _controller.stop();
        } else {
          _controller.repeat();
        }
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * pi,
              child: child,
            );
          },
          child: QueryArtworkWidget(
            keepOldArtwork: true,
            id: widget.id,
            type: ArtworkType.AUDIO,
            size: 500,
            quality: 100,
            artworkBorder: BorderRadius.circular(100),
            nullArtworkWidget: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(Icons.music_note_outlined),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: child,
        );
      },
      child: QueryArtworkWidget(
        id: widget.id,
        type: ArtworkType.AUDIO,
        artworkQuality: FilterQuality.high,
        quality: 100,
        artworkBorder: BorderRadius.circular(100),
        nullArtworkWidget: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.music_note_outlined),
        ),
      ),
    );
  }
}

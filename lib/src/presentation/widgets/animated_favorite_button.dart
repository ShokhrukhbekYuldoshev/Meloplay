import 'package:flutter/material.dart';

class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final Function onTap;

  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward();
        widget.onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16, bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Transform.scale(
          scale: _animation.value,
          child: Icon(
            widget.isFavorite
                ? Icons.favorite_outlined
                : Icons.favorite_border_outlined,
            color: widget.isFavorite ? Colors.red : Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

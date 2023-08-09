import 'package:flutter/material.dart';

class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final Function(bool) onChanged;

  const AnimatedFavoriteButton({
    Key? key,
    required this.isFavorite,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller);
    _scaleAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
    _colorAnimation = ColorTween(
      begin: Colors.grey[400],
      end: Colors.red,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isFavorite) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
        widget.onChanged(!widget.isFavorite);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          Icons.favorite_rounded,
          color: _colorAnimation.value,
        ),
      ),
    );
  }
}

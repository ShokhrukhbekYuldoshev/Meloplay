import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SharedAxisPageRoute({required this.child})
    : super(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
          );
        },
      );
}

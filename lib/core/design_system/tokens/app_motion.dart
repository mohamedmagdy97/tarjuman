import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration transition = Duration(milliseconds: 250);
  static const Duration sheet = Duration(milliseconds: 400);
  static const Duration cue = Duration(milliseconds: 120);
  static const Duration controlsHide = Duration(seconds: 3);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
}

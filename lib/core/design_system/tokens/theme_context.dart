import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/tokens/app_colors.dart';

extension ThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

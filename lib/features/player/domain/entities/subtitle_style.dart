import 'package:equatable/equatable.dart';

enum SubtitleColorPreset { white, saffron, lagoon, softGrey }

enum SubtitleBackground { box, outline, none }

enum SubtitlePosition { bottom, top }

class SubtitleStyle extends Equatable {
  const SubtitleStyle({
    this.fontSize = 22,
    this.color = SubtitleColorPreset.white,
    this.background = SubtitleBackground.box,
    this.position = SubtitlePosition.bottom,
  });

  static const minFontSize = 16.0;
  static const maxFontSize = 36.0;

  final double fontSize;
  final SubtitleColorPreset color;
  final SubtitleBackground background;
  final SubtitlePosition position;

  SubtitleStyle copyWith({
    double? fontSize,
    SubtitleColorPreset? color,
    SubtitleBackground? background,
    SubtitlePosition? position,
  }) => SubtitleStyle(
    fontSize: (fontSize ?? this.fontSize).clamp(minFontSize, maxFontSize),
    color: color ?? this.color,
    background: background ?? this.background,
    position: position ?? this.position,
  );

  @override
  List<Object?> get props => [fontSize, color, background, position];
}

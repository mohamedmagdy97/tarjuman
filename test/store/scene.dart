import 'package:flutter/material.dart';
import 'package:tarjuman/core/platform/media/player_engine.dart';

/// Stylised "video frame" used behind the player in store graphics.
class SceneBackdrop extends StatelessWidget {
  const SceneBackdrop({super.key});

  @override
  Widget build(BuildContext context) =>
      const SizedBox.expand(child: CustomPaint(painter: _ScenePainter()));
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF16384B), Color(0xFF1B2A44), Color(0xFF0B1020)],
          stops: [0, .55, 1],
        ).createShader(rect),
    );
    final sun = Offset(size.width * .72, size.height * .30);
    canvas.drawCircle(
      sun,
      size.width * .30,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD27A),
            const Color(0xFFFFB84A).withValues(alpha: .55),
            Colors.transparent,
          ],
          stops: const [0, .35, 1],
        ).createShader(Rect.fromCircle(center: sun, radius: size.width * .30)),
    );
    void ridge(double base, double amp, Color c, double phase) {
      final path = Path()..moveTo(0, size.height);
      for (var x = 0.0; x <= size.width; x += 6) {
        final y =
            size.height * base -
            amp * (0.5 + 0.5 * _wave(x / size.width * 6 + phase));
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = c);
    }

    ridge(.62, size.height * .10, const Color(0xFF16263A), 0.4);
    ridge(.72, size.height * .09, const Color(0xFF101C2D), 2.1);
    ridge(.82, size.height * .07, const Color(0xFF0A1220), 4.3);
  }

  double _wave(double v) =>
      (v - v.floorToDouble() - .5).abs() * 2 * (1 - (v * .37 % 1) * .3);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SceneEngine implements PlayerEngine {
  @override
  Stream<PlaybackSnapshot> get snapshots => const Stream.empty();
  @override
  Future<void> open(String path) async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> seekTo(Duration position) async {}
  @override
  Future<void> setSpeed(double speed) async {}
  @override
  Widget buildSurface() => const SceneBackdrop();
  @override
  Future<void> dispose() async {}
}

@Tags(['store'])
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screens.dart';

const _ink = Color(0xFF0A0D14);
const _saffron = Color(0xFFFFC93C);
const _lagoon = Color(0xFF35D0BA);
const _muted = Color(0xFFA9B3C9);

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(
        Future.value(
          ByteData.sublistView(File('assets/fonts/$f').readAsBytesSync()),
        ),
      );
    }
    await loader.load();
  }

  await load('IBMPlexSansArabic', [
    'IBMPlexSansArabic-Regular.ttf',
    'IBMPlexSansArabic-Medium.ttf',
    'IBMPlexSansArabic-SemiBold.ttf',
    'IBMPlexSansArabic-Bold.ttf',
  ]);
  await load('ReemKufi', ['ReemKufi.ttf']);
  final icons = File(
    '${Platform.environment['HOME']}/dev/v3.41/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  await (FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync()))))
      .load();
  await load('IBMPlexMono', ['IBMPlexMono-Medium.ttf']);
}

Future<ui.Image> _render(
  WidgetTester t,
  Widget w,
  Size logical,
  double dpr,
) async {
  t.view
    ..physicalSize = logical * dpr
    ..devicePixelRatio = dpr;
  final key = GlobalKey();
  await t.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: key,
        child: SizedBox.fromSize(size: logical, child: w),
      ),
    ),
  );
  await t.pump(const Duration(milliseconds: 200));
  await t.pump(const Duration(seconds: 1));
  late ui.Image img;
  await t.runAsync(() async {
    final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    img = await b.toImage(pixelRatio: dpr);
  });
  return img;
}

Future<void> _save(WidgetTester t, ui.Image img, String path) async {
  await t.runAsync(() async {
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!;
    final f = File(path);
    await f.parent.create(recursive: true);
    await f.writeAsBytes(bytes.buffer.asUint8List());
  });
}

// ---- marketing copy ---------------------------------------------------------
class _Copy {
  const _Copy(this.headline, this.sub, [this.chip, this.chipTone]);
  final String headline;
  final String sub;
  final String? chip;
  final Color? chipTone;
}

const _ar = <String, _Copy>{
  '01-library': _Copy(
    'شاهد أي فيديو بالعربي',
    'ترجمة عربية لكل فيديو إنجليزي، على جهازك',
  ),
  '02-player': _Copy(
    'ترجمة عربية متزامنة',
    'تظهر فوق الفيديو في لحظة الكلام نفسها',
  ),
  '03-processing': _Copy(
    'جهّز الترجمة ثم شاهد',
    'تقدّم واضح، ويكمل من حيث توقف',
  ),
  '04-setup': _Copy(
    'على جهازك أو عبر الإنترنت',
    'أنت تختار مكان المعالجة. الصوت يبقى عندك افتراضيًا',
    'الصوت لا يغادر هاتفك',
    _lagoon,
  ),
  '05-models': _Copy(
    'يعمل بدون إنترنت',
    'حمّل النماذج مرة واحدة وترجم في أي مكان',
    'جاهز بدون إنترنت',
    _lagoon,
  ),
  '06-style': _Copy('خصّص شكل الترجمة', 'الحجم واللون والخلفية والمكان'),
  '07-editor': _Copy('عدّل الترجمة وصدّرها', 'ابحث وعدّل أي سطر وصدّر ملف SRT'),
  '08-settings': _Copy(
    'خصوصية بإيدك',
    'المعالجة على الجهاز أساسًا، والأونلاين اختياري بموافقتك',
  ),
};

const _en = <String, _Copy>{
  '01-library': _Copy(
    'Watch any video in Arabic',
    'Arabic subtitles for English videos, on your device',
  ),
  '02-player': _Copy(
    'Arabic subtitles, in sync',
    'Shown over the video the moment it is spoken',
  ),
  '03-processing': _Copy(
    'Prepare, then watch',
    'Clear progress that resumes where it stopped',
  ),
  '04-setup': _Copy(
    'On your device or online',
    'You choose where it runs. Audio stays with you by default',
    'Audio never leaves your phone',
    _lagoon,
  ),
  '05-models': _Copy(
    'Works without internet',
    'Download models once, translate anywhere',
    'Ready offline',
    _lagoon,
  ),
  '06-style': _Copy(
    'Make subtitles yours',
    'Size, colour, background and position',
  ),
  '07-editor': _Copy(
    'Edit and export',
    'Search, fix any line and export an SRT file',
  ),
  '08-settings': _Copy(
    'Privacy in your hands',
    'On-device by default, online only with your consent',
  ),
};

// ---- composition widgets ------------------------------------------------------
class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0E1424), _ink],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -260,
          top: -260,
          child: Container(
            width: 760,
            height: 760,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_saffron.withValues(alpha: .20), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          left: -300,
          bottom: 200,
          child: Container(
            width: 700,
            height: 700,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_lagoon.withValues(alpha: .10), Colors.transparent],
              ),
            ),
          ),
        ),
        child,
      ],
    ),
  );
}

class _Phone extends StatelessWidget {
  const _Phone({required this.image, required this.width});
  final ui.Image image;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * image.height / image.width;
    final radius = width * .095;
    return Container(
      width: width + 20,
      height: height + 20,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF05070B),
        borderRadius: BorderRadius.circular(radius + 10),
        border: Border.all(color: const Color(0xFF2A3350), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .55),
            blurRadius: 60,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: RawImage(image: image, fit: BoxFit.fill),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.tone});
  final String text;
  final Color tone;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
    decoration: BoxDecoration(
      color: const Color(0xFF11151F),
      borderRadius: BorderRadius.circular(60),
      border: Border.all(color: tone.withValues(alpha: .7), width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .5),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

class _StoreFrame extends StatelessWidget {
  const _StoreFrame({
    required this.copy,
    required this.shot,
    required this.rtl,
  });
  final _Copy copy;
  final ui.Image shot;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    final dir = rtl ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(
      textDirection: dir,
      child: _Backdrop(
        child: Stack(
          children: [
            Positioned(
              top: 112,
              left: 70,
              right: 70,
              child: Column(
                children: [
                  Text(
                    copy.headline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: rtl ? 'ReemKufi' : 'IBMPlexSansArabic',
                      fontSize: 80,
                      height: 1.22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    copy.sub,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 38,
                      height: 1.45,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 470,
              left: (1080 - 700) / 2 - 10,
              child: _Phone(image: shot, width: 700),
            ),
            if (copy.chip != null)
              Positioned(
                top: 1560,
                right: rtl ? null : 24,
                left: rtl ? 24 : null,
                child: Transform.rotate(
                  angle: rtl ? -.04 : .04,
                  child: _Chip(
                    text: copy.chip!,
                    tone: copy.chipTone ?? _saffron,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Mark extends CustomPainter {
  const _Mark({this.background = true, this.scale = 1.12});
  final bool background;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Offset.zero & size;
    if (background) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF141B30), _ink],
          ).createShader(rect),
      );
      // ignore: cascade_invocations, kept separate for readability of the painter
      canvas.drawCircle(
        Offset(s * .78, s * .18),
        s * .55,
        Paint()
          ..shader =
              RadialGradient(
                colors: [_saffron.withValues(alpha: .22), Colors.transparent],
              ).createShader(
                Rect.fromCircle(
                  center: Offset(s * .78, s * .18),
                  radius: s * .55,
                ),
              ),
      );
    }
    final c = Offset(s / 2, s / 2);
    double d(double v) => v * s * scale;
    // screen frame
    final frame = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: d(.62), height: d(.46)),
      Radius.circular(d(.11)),
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = d(.034)
        ..color = const Color(0xFF5A6788),
    );
    // original line (short, white) and translated line (long, saffron)
    RRect bar(double cx, double cy, double w, double h) =>
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
          Radius.circular(h / 2),
        );
    canvas
      ..drawRRect(
        bar(c.dx - d(.07), c.dy - d(.045), d(.30), d(.052)),
        Paint()..color = const Color(0xFFEEF1F7).withValues(alpha: .9),
      )
      ..drawRRect(
        bar(c.dx, c.dy + d(.055), d(.44), d(.075)),
        Paint()..color = _saffron,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic({
    required this.title,
    required this.tagline,
    required this.a,
    required this.b,
    required this.rtl,
  });
  final String title;
  final String tagline;
  final ui.Image a;
  final ui.Image b;
  final bool rtl;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF141B30), _ink],
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              top: -200,
              right: rtl ? null : -120,
              left: rtl ? -120 : null,
              child: Container(
                width: 620,
                height: 620,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _saffron.withValues(alpha: .22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: rtl ? null : 56,
              right: rtl ? 56 : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: const CustomPaint(painter: _Mark()),
                        ),
                      ),
                      const SizedBox(width: 22),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: rtl ? 'ReemKufi' : 'IBMPlexSansArabic',
                          fontSize: 80,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: 400,
                    child: Text(
                      tagline,
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 31,
                        height: 1.45,
                        color: _muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 44,
              right: rtl ? null : 24,
              left: rtl ? 24 : null,
              child: Transform.rotate(
                angle: rtl ? .09 : -.09,
                child: _Phone(image: a, width: 225),
              ),
            ),
            Positioned(
              top: 150,
              right: rtl ? null : 214,
              left: rtl ? 214 : null,
              child: Transform.rotate(
                angle: rtl ? .09 : -.09,
                child: _Phone(image: b, width: 225),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  final enabled = Platform.environment.containsKey('STORE_ASSETS');

  testWidgets('generate Play Store assets', (tester) async {
    await _loadFonts();
    const out = 'store/android';

    // 1) icon
    final icon512 = await _render(
      tester,
      const CustomPaint(painter: _Mark()),
      const Size(512, 512),
      1,
    );
    await _save(tester, icon512, '$out/icon-512.png');
    final icon1024 = await _render(
      tester,
      const CustomPaint(painter: _Mark()),
      const Size(1024, 1024),
      1,
    );
    await _save(tester, icon1024, 'assets/icon/icon.png');
    final fg = await _render(
      tester,
      const CustomPaint(painter: _Mark(background: false, scale: .9)),
      const Size(1024, 1024),
      1,
    );
    await _save(tester, fg, 'assets/icon/icon_foreground.png');

    // 2) real app screens -> marketing frames, per language
    for (final entry in {
      'ar': (const Locale('ar'), _ar, true),
      'en': (const Locale('en'), _en, false),
    }.entries) {
      final (locale, copy, rtl) = entry.value;
      final shots = <String, ui.Image>{};
      for (final s in storeScreens().entries) {
        final raw = await _render(
          tester,
          Stack(
            children: [
              s.value(locale),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: StatusBarMock(),
              ),
            ],
          ),
          const Size(360, 720),
          3,
        );
        shots[s.key] = raw;
        await _save(tester, raw, 'store/raw/${entry.key}/${s.key}.png');
      }
      for (final e in shots.entries) {
        final frame = await _render(
          tester,
          _StoreFrame(copy: copy[e.key]!, shot: e.value, rtl: rtl),
          const Size(1080, 1920),
          1,
        );
        await _save(
          tester,
          frame,
          '$out/${entry.key}/phone-screenshots/${e.key}.png',
        );
      }
      final feature = await _render(
        tester,
        _FeatureGraphic(
          title: rtl ? 'ترجمان' : 'Tarjuman',
          tagline: rtl
              ? 'شاهد أي فيديو بالعربي\nحتى بدون إنترنت.'
              : 'Watch any video in Arabic,\neven offline.',
          a: shots['02-player']!,
          b: shots['01-library']!,
          rtl: rtl,
        ),
        const Size(1024, 500),
        1,
      );
      await _save(
        tester,
        feature,
        '$out/${entry.key}/feature-graphic-1024x500.png',
      );
    }
    addTearDown(() => tester.view.reset());
  }, skip: !enabled);

  test('(store assets are skipped unless STORE_ASSETS=1)', () {
    expect(math.pi, greaterThan(3));
  });
}

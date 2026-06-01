import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Renders server-provided captcha digits in a classic noisy image style.
class LoginCaptchaCanvas extends StatelessWidget {
  const LoginCaptchaCanvas({
    required this.code,
    required this.seed,
    this.width = 112,
    this.height = 40,
    super.key,
  });

  final String code;
  final int seed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _LoginCaptchaPainter(code: code, seed: seed),
      ),
    );
  }
}

class _LoginCaptchaPainter extends CustomPainter {
  _LoginCaptchaPainter({
    required this.code,
    required this.seed,
  });

  final String code;
  final int seed;

  static const _background = Color(0xFFF3F3F3);
  static const _digitColors = <Color>[
    Color(0xFF2E3A59),
    Color(0xFF3D3D3D),
    Color(0xFF4A5A3C),
    Color(0xFF3A322E),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final rect = Offset.zero & size;

    canvas.drawRect(rect, Paint()..color = _background);

    _drawNoiseDots(canvas, size, rng);
    _drawInterferenceLines(canvas, size, rng, behindDigits: true);

    final chars = code.split('');
    if (chars.isEmpty) return;

    final slot = size.width / chars.length;
    for (var i = 0; i < chars.length; i++) {
      final color = _digitColors[i % _digitColors.length];
      final fontSize = 21 + rng.nextInt(4).toDouble();
      final char = chars[i];

      final builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      )
        ..pushStyle(ui.TextStyle(color: color))
        ..addText(char);

      final paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: slot));

      final cx = slot * i + slot / 2;
      final cy = size.height / 2 + (rng.nextDouble() - 0.5) * 8;
      final angle = (rng.nextDouble() - 0.5) * 0.45;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.drawParagraph(
        paragraph,
        Offset(-paragraph.maxIntrinsicWidth / 2, -paragraph.height / 2),
      );
      canvas.restore();
    }

    _drawInterferenceLines(canvas, size, rng, behindDigits: false);
  }

  void _drawNoiseDots(Canvas canvas, Size size, math.Random rng) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 48; i++) {
      paint.color = Color.fromARGB(
        55 + rng.nextInt(70),
        40 + rng.nextInt(50),
        40 + rng.nextInt(50),
        40 + rng.nextInt(50),
      );
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        0.6 + rng.nextDouble() * 0.8,
        paint,
      );
    }
  }

  void _drawInterferenceLines(
    Canvas canvas,
    Size size,
    math.Random rng, {
    required bool behindDigits,
  }) {
    final lineCount = behindDigits ? 3 : 2;
    for (var i = 0; i < lineCount; i++) {
      final paint = Paint()
        ..color = Color.fromARGB(
          behindDigits ? 90 : 120,
          90 + rng.nextInt(60),
          90 + rng.nextInt(60),
          90 + rng.nextInt(60),
        )
        ..strokeWidth = 0.8 + rng.nextDouble() * 0.6
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LoginCaptchaPainter oldDelegate) {
    return oldDelegate.code != code || oldDelegate.seed != seed;
  }
}

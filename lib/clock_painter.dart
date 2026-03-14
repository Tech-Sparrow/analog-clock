import 'dart:math';

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// REASONING: Light vs dark and scaling
// ---------------------------------------------------------------------------
// We take [brightness] from the app theme so the dial looks correct in both
// themes. _isDark drives all color choices: dark theme = dark face, light
// text/ticks/hands; light theme = light face, dark text/ticks/hands. Second
// hand and center cap stay teal (#00D4AA) in both for a consistent accent.
// All sizes (stroke widths, font sizes, radii) are fractions of [radius] so
// the clock looks the same on every device; we avoid fixed pixel values.
// shouldRepaint returns true so the hands redraw every second (time changes).
// ---------------------------------------------------------------------------

class ClockPainter extends CustomPainter {
  ClockPainter({required this.brightness});

  final Brightness brightness;

  bool get _isDark => brightness == Brightness.dark;

  // All dimensions are radius-relative so the clock scales identically on any device.
  static const double _bezelWidth = 0.04;
  static const double _tickInner = 0.72;
  static const double _tickOuter = 0.92;
  static const double _digitRadius = 0.58;
  static const double _hourHandLength = 0.48;
  static const double _minuteHandLength = 0.62;
  static const double _secondHandLength = 0.78;
  static const double _centerCapRadius = 0.04;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.shortestSide / 2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final DateTime now = DateTime.now();
    final Rect circleRect = Rect.fromCircle(center: Offset(centerX, centerY), radius: radius);

    // 1) Background circle with radial gradient (depth effect)
    final Gradient faceGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: _isDark
          ? [
              const Color(0xFF2D2D3A),
              const Color(0xFF1E1E28),
              const Color(0xFF15151C),
            ]
          : [
              const Color(0xFFF5F6F8),
              const Color(0xFFE8ECF0),
              const Color(0xFFD5DCE4),
            ],
      stops: const [0.0, 0.6, 1.0],
    );
    canvas.drawCircle(
        Offset(centerX, centerY), radius, Paint()..shader = faceGradient.createShader(circleRect));

    // 2) Bezel ring (metallic accent)
    final Paint bezelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDark
            ? [
                const Color(0xFF4A4A5C),
                const Color(0xFF2D2D3A),
                const Color(0xFF3D3D4D),
              ]
            : [
                const Color(0xFFB0B8C4),
                const Color(0xFFE0E4E8),
                const Color(0xFFC4CAD4),
              ],
      ).createShader(circleRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * _bezelWidth;
    canvas.drawCircle(Offset(centerX, centerY), radius - (radius * _bezelWidth / 2), bezelPaint);

    // 3) Tick marks (scale with radius)
    final double tickStroke = radius * 0.012;
    final Color majorTickColor = _isDark ? const Color(0xFFE8E8ED) : const Color(0xFF2D2D3A);
    final Color minorTickColor = _isDark ? const Color(0xFF6B6B7A) : const Color(0xFF9A9AAA);
    final Paint majorTickPaint = Paint()
      ..color = majorTickColor
      ..strokeWidth = tickStroke * 2
      ..strokeCap = StrokeCap.round;
    final Paint minorTickPaint = Paint()
      ..color = minorTickColor
      ..strokeWidth = tickStroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final double angle = 2 * pi * (i / 60) - (pi / 2);
      final double x1 = centerX + radius * _tickInner * cos(angle);
      final double y1 = centerY + radius * _tickInner * sin(angle);
      final double x2 = centerX + radius * _tickOuter * cos(angle);
      final double y2 = centerY + radius * _tickOuter * sin(angle);
      final bool isMajor = i % 5 == 0;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), isMajor ? majorTickPaint : minorTickPaint);
    }

    // 4) Hour digits 1–12 (radius-scaled font, same proportions on all devices)
    final double fontSize = radius * 0.14;
    final Color digitColor = _isDark ? const Color(0xFFE8E8ED) : const Color(0xFF2D2D3A);
    final TextStyle digitStyle = TextStyle(
      color: digitColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(
          color: (_isDark ? Colors.black : Colors.white).withOpacity(0.4),
          blurRadius: radius * 0.02,
          offset: Offset(0, radius * 0.008),
        ),
      ],
    );
    for (int i = 0; i < 12; i++) {
      final int digit = i == 0 ? 12 : i;
      final double angle = 2 * pi * (i / 12) - (pi / 2);
      final double x = centerX + radius * _digitRadius * cos(angle);
      final double y = centerY + radius * _digitRadius * sin(angle);

      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: '$digit', style: digitStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // 5) Day and date at bottom center, above digit 6
    const List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final String dayStr = weekdays[now.weekday - 1];
    final String dateStr = '${months[now.month - 1]} ${now.day}, ${now.year}';
    final double dateY = centerY + radius * 0.26;
    final double dayFontSize = radius * 0.08;
    final double dateFontSize = radius * 0.065;
    final Color dayColor = _isDark ? const Color(0xFFE8E8ED) : const Color(0xFF2D2D3A);
    final Color dateColor = _isDark ? const Color(0xFFA0A0B0) : const Color(0xFF5A5A6A);
    final TextStyle dayStyle = TextStyle(
      color: dayColor,
      fontSize: dayFontSize,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(
          color: (_isDark ? Colors.black : Colors.white).withOpacity(0.4),
          blurRadius: radius * 0.015,
          offset: Offset(0, radius * 0.006),
        ),
      ],
    );
    final TextStyle dateStyle = TextStyle(
      color: dateColor,
      fontSize: dateFontSize,
      fontWeight: FontWeight.w500,
      shadows: [
        Shadow(
          color: (_isDark ? Colors.black : Colors.white).withOpacity(0.3),
          blurRadius: radius * 0.01,
          offset: Offset(0, radius * 0.004),
        ),
      ],
    );
    final TextPainter dayPainter = TextPainter(
      text: TextSpan(text: dayStr, style: dayStyle),
      textDirection: TextDirection.ltr,
    );
    dayPainter.layout();
    dayPainter.paint(
      canvas,
      Offset(centerX - dayPainter.width / 2, dateY - dayPainter.height - radius * 0.02),
    );
    final TextPainter datePainter = TextPainter(
      text: TextSpan(text: dateStr, style: dateStyle),
      textDirection: TextDirection.ltr,
    );
    datePainter.layout();
    datePainter.paint(
      canvas,
      Offset(centerX - datePainter.width / 2, dateY),
    );

    // 6) Clock hands (all stroke widths and lengths scale with radius)
    final double secondAngle = 2 * pi * (now.second / 60) - (pi / 2);
    final double minuteAngle = 2 * pi * (now.minute / 60) - (pi / 2);
    final double hourAngle = 2 * pi * ((now.hour % 12 + now.minute / 60) / 12) - (pi / 2);

    final double hourStroke = radius * 0.022;
    final double minuteStroke = radius * 0.014;
    final double secondStroke = radius * 0.006;

    final Color handColor = _isDark ? const Color(0xFFE8E8ED) : const Color(0xFF2D2D3A);
    drawClockHand(
      canvas,
      centerX,
      centerY,
      radius * _hourHandLength,
      hourAngle,
      Paint()
        ..color = handColor
        ..strokeWidth = hourStroke
        ..strokeCap = StrokeCap.round,
    );
    drawClockHand(
      canvas,
      centerX,
      centerY,
      radius * _minuteHandLength,
      minuteAngle,
      Paint()
        ..color = handColor
        ..strokeWidth = minuteStroke
        ..strokeCap = StrokeCap.round,
    );
    drawClockHand(
      canvas,
      centerX,
      centerY,
      radius * _secondHandLength,
      secondAngle,
      Paint()
        ..color = const Color(0xFF00D4AA)
        ..strokeWidth = secondStroke
        ..strokeCap = StrokeCap.round,
    );

    // 7) Center cap
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius * _centerCapRadius,
      Paint()
        ..color = const Color(0xFF00D4AA)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius * _centerCapRadius,
      Paint()
        ..color = handColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.004,
    );
  }

  void drawClockHand(Canvas canvas, double x, double y, double length, double angle, Paint paint) {
    final double handX = x + length * cos(angle);
    final double handY = y + length * sin(angle);
    canvas.drawLine(Offset(x, y), Offset(handX, handY), paint);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => true; // Repaint every second for hands; also when brightness changes
}

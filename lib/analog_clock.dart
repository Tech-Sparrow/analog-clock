import 'dart:async';

import 'package:analog_clock_demo/clock_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

// ---------------------------------------------------------------------------
// REASONING: How theme and tap work
// ---------------------------------------------------------------------------
// We read Theme.of(context).brightness so the clock and background always
// match the app theme (which is either system or user-toggled). We pass that
// brightness into ClockPainter so the dial colors (face, ticks, digits,
// hands) match. On tap we call onThemeToggle(Theme.of(context).brightness)
// so the parent can switch to the opposite theme; we don't store theme
// here, the parent (MyApp) does. Timer.periodic(1s) is only for updating
// the clock hands every second. When isScreenSaver is true we keep the screen
// on (wakelock) and on tap we call onScreenSaverTap to exit (e.g. SystemNavigator.pop).
// ---------------------------------------------------------------------------

class AnalogClock extends StatefulWidget {
  const AnalogClock({
    super.key,
    this.onThemeToggle,
    this.isScreenSaver = false,
    this.onScreenSaverTap,
  });

  /// Called when the user taps the dial (normal mode). Receives current brightness so app can toggle to the opposite.
  final void Function(Brightness currentBrightness)? onThemeToggle;

  /// When true, screen is kept on (wakelock) and tap calls [onScreenSaverTap] to exit.
  final bool isScreenSaver;

  /// When [isScreenSaver] is true, called on tap to exit screen saver (e.g. SystemNavigator.pop).
  final VoidCallback? onScreenSaverTap;

  @override
  AnalogClockState createState() => AnalogClockState();
}

class AnalogClockState extends State<AnalogClock> {
  @override
  void initState() {
    super.initState();
    if (widget.isScreenSaver) {
      Wakelock.enable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.isScreenSaver) {
      Wakelock.disable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> backgroundGradient = isDark
        ? [
            const Color(0xFF0F0F14),
            const Color(0xFF1A1A24),
            const Color(0xFF0F0F14),
          ]
        : [
            const Color(0xFFE8ECF0),
            const Color(0xFFD5DCE4),
            const Color(0xFFE8ECF0),
          ];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundGradient,
        ),
      ),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double side = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight;
            return GestureDetector(
              onTap: () {
                if (widget.isScreenSaver) {
                  widget.onScreenSaverTap?.call();
                } else {
                  widget.onThemeToggle?.call(Theme.of(context).brightness);
                }
              },
              child: SizedBox(
                width: side,
                height: side,
                child: CustomPaint(
                  painter: ClockPainter(brightness: isDark ? Brightness.dark : Brightness.light),
                  size: Size(side, side),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

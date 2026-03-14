import 'package:analog_clock_demo/analog_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// REASONING: Theme handling
// ---------------------------------------------------------------------------
// We start with ThemeMode.system so the app matches the device (light/dark).
// When the user taps the dial, we want to *toggle* to the opposite of what
// they see now. So we take currentBrightness from the clock and set theme
// to the opposite (dark -> light, light -> dark). We store ThemeMode.light
// or ThemeMode.dark (not system) after a tap so the choice sticks until
// the next tap. We do NOT cycle back to system automatically.
// ---------------------------------------------------------------------------
// REASONING: Screen saver (Android Daydream)
// ---------------------------------------------------------------------------
// When launched as screen saver, Android passes initial route "/screensaver"
// from MainActivity.getInitialRoute(). We show the clock with wakelock on;
// tap exits (SystemNavigator.pop()) so the user returns to lock screen.
// ---------------------------------------------------------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final String initialRoute = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.initialRoute = '/'});

  final String initialRoute;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// System theme by default; after first tap we use light or dark explicitly.
  ThemeMode _themeMode = ThemeMode.system;

  /// Toggle theme to the opposite of [currentBrightness] so one tap = flip.
  void _onThemeToggle(Brightness currentBrightness) {
    setState(() {
      _themeMode = currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isScreenSaver = widget.initialRoute == '/screensaver';

    return MaterialApp(
      title: 'Analog Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D4AA),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D4AA),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: AnalogClock(
        onThemeToggle: isScreenSaver ? null : _onThemeToggle,
        isScreenSaver: isScreenSaver,
        onScreenSaverTap: isScreenSaver ? () => SystemNavigator.pop() : null,
      ),
    );
  }
}

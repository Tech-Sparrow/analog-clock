// ignore_for_file: avoid_print
// Run from project root: dart run tool/generate_icon.dart
// Generates assets/icon/app_icon.png (1024x1024) - a catchy analog clock logo.

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

img.ColorUint8 colorFromHex(int hex) {
  final int a = (hex >> 24) & 0xFF;
  final int r = (hex >> 16) & 0xFF;
  final int g = (hex >> 8) & 0xFF;
  final int b = hex & 0xFF;
  return img.ColorUint8.rgba(r, g, b, a == 0 ? 255 : a);
}

void main() {
  const int size = 1024;
  const int center = size ~/ 2;

  // Colors (matching app: dark face, light elements, teal accent)
  final background = colorFromHex(0xFF1E1E28);
  final faceLight = colorFromHex(0xFFE8ECF0);
  final handColor = colorFromHex(0xFF2D2D3A);
  final teal = colorFromHex(0xFF00D4AA);
  final outline = colorFromHex(0xFFD5DCE4);

  img.Image image = img.Image(width: size, height: size);
  img.fill(image, color: background);

  // Outer ring (bezel) - teal, then main face circle
  const int faceRadius = 420;
  const int bezelWidth = 28;
  for (int r = faceRadius + bezelWidth; r >= faceRadius; r--) {
    img.drawCircle(image, x: center, y: center, radius: r, color: teal);
  }
  img.fillCircle(image, x: center, y: center, radius: faceRadius, color: faceLight);

  // Inner ring (subtle) - dark outline
  img.drawCircle(image, x: center, y: center, radius: faceRadius - 20, color: outline);

  // Clock hands at 10:10 (classic watch ad pose)
  const int hourLen = 140;
  const int minuteLen = 200;
  const int handThickness = 24;

  double hourAngle = -300 * math.pi / 180;
  double minuteAngle = -60 * math.pi / 180;

  int hourX = center + (hourLen * math.sin(hourAngle)).round();
  int hourY = center - (hourLen * math.cos(hourAngle)).round();
  int minuteX = center + (minuteLen * math.sin(minuteAngle)).round();
  int minuteY = center - (minuteLen * math.cos(minuteAngle)).round();

  img.drawLine(
    image,
    x1: center,
    y1: center,
    x2: hourX,
    y2: hourY,
    color: handColor,
    thickness: handThickness,
  );
  img.drawLine(
    image,
    x1: center,
    y1: center,
    x2: minuteX,
    y2: minuteY,
    color: handColor,
    thickness: handThickness,
  );

  // Center cap - teal dot
  img.fillCircle(image, x: center, y: center, radius: 36, color: teal);
  img.drawCircle(image, x: center, y: center, radius: 36, color: faceLight);

  final Directory dir = Directory('assets/icon');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final File out = File('assets/icon/app_icon.png');
  out.writeAsBytesSync(img.encodePng(image));
  print('Generated ${out.path} (${size}x$size)');
}

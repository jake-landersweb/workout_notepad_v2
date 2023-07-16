import 'package:flutter/material.dart';
import 'dart:math' as math;

Map<int, Color> getSwatch(Color color) {
  final hslColor = HSLColor.fromColor(color);
  final lightness = hslColor.lightness;

  /// if [500] is the default color, there are at LEAST five
  /// steps below [500]. (i.e. 400, 300, 200, 100, 50.) A
  /// divisor of 5 would mean [50] is a lightness of 1.0 or
  /// a color of #ffffff. A value of six would be near white
  /// but not quite.
  const lowDivisor = 6;

  /// if [500] is the default color, there are at LEAST four
  /// steps above [500]. A divisor of 4 would mean [900] is
  /// a lightness of 0.0 or color of #000000
  const highDivisor = 5;

  final lowStep = (1.0 - lightness) / lowDivisor;
  final highStep = lightness / highDivisor;

  return {
    50: (hslColor.withLightness(lightness + (lowStep * 5))).toColor(),
    100: (hslColor.withLightness(lightness + (lowStep * 4))).toColor(),
    200: (hslColor.withLightness(lightness + (lowStep * 3))).toColor(),
    300: (hslColor.withLightness(lightness + (lowStep * 2))).toColor(),
    400: (hslColor.withLightness(lightness + lowStep)).toColor(),
    500: (hslColor.withLightness(lightness)).toColor(),
    600: (hslColor.withLightness(lightness - highStep)).toColor(),
    700: (hslColor.withLightness(lightness - (highStep * 2))).toColor(),
    800: (hslColor.withLightness(lightness - (highStep * 3))).toColor(),
    900: (hslColor.withLightness(lightness - (highStep * 4))).toColor(),
  };
}

extension ColorUtil on Color {
  static Color random(String seed) {
    int num = 0;
    for (int i = 0; i < seed.length; i++) {
      num += seed[i].codeUnitAt(0);
    }
    // add lightness to make it look better overall
    Color col = Color((math.Random(num).nextDouble() * 0xFFFFFF).toInt())
        .withOpacity(1.0);
    HSLColor hsl = HSLColor.fromColor(col);
    return hsl.withLightness(0.75).toColor();
  }

  static Color hexToColor(String hexColor) {
    // Remove the leading '#' character
    hexColor = hexColor.replaceAll("#", "");

    // Check if the color code is valid
    if (hexColor.length != 6) {
      throw Exception(
          "Invalid hex color code. The code must be 6 characters long.");
    }

    // Parse the hex color code
    int colorValue = int.parse(hexColor, radix: 16);

    // Return the corresponding Color object
    return Color(colorValue | 0xFF000000);
  }
}

extension AppColors on Color {
  static Color background(BuildContext context) {
    return ColorUtil.hexToColor("#e1dcd2");
  }

  static MaterialColor cell(BuildContext context) {
    return const MaterialColor(0xFFF5F0E6, {
      50: Color(0xFFFCFAF6),
      100: Color(0xFFF9F7F1),
      200: Color(0xFFF5F0E6),
      300: Color(0xFFF1E9DB),
      400: Color(0xFFECE3D0),
      500: Color(0xFFE8DCC5),
      600: Color(0xFFE4D6BA),
      700: Color(0xFFDFCFAF),
      800: Color(0xFFDBC9A4),
      900: Color(0xFFD6C29A),
      950: Color(0xFFD4BF94),
    });
  }

  static Color text(BuildContext context) {
    return ColorUtil.hexToColor("#231f20");
  }

  static Color subtext(BuildContext context) {
    return text(context).withOpacity(0.63);
  }

  static Color light(BuildContext context) {
    return text(context).withOpacity(0.3);
  }

  static Color divider(BuildContext context) {
    return text(context).withOpacity(0.065);
  }
}

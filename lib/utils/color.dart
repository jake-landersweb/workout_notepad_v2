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
  final lowDivisor = 6;

  /// if [500] is the default color, there are at LEAST four
  /// steps above [500]. A divisor of 4 would mean [900] is
  /// a lightness of 0.0 or color of #000000
  final highDivisor = 5;

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
  static Color bgLight = ColorUtil.hexToColor("#E2E5ED");
  static Color cellLight = ColorUtil.hexToColor("#FAFAFC");

  static Color bgDark = ColorUtil.hexToColor("#23282F");
  static Color cellDark = ColorUtil.hexToColor("#343C46");

  static Color background(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return bgLight;
    } else {
      return bgDark;
    }
  }

  static Color sheetBackground(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return ColorUtil.hexToColor("#ffffff");
    } else {
      return bgDark;
    }
  }

  static Color cell(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return ColorUtil.hexToColor("#FAFAFC");
    } else {
      return cellDark;
    }
  }

  static Color sheetCell(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return ColorUtil.hexToColor("#ffffff");
    } else {
      return bgDark;
    }
  }

  static Color text(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  static Color subText(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return Colors.black.withOpacity(0.7);
    } else {
      return Colors.white.withOpacity(0.7);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:workout_notepad_v2/text_themes.dart';

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color primaryColor;

  AppColorScheme({required this.primaryColor});

  @override
  ThemeExtension<AppColorScheme> copyWith({
    Color? primaryColor,
  }) =>
      AppColorScheme(primaryColor: primaryColor ?? this.primaryColor);

  @override
  ThemeExtension<AppColorScheme> lerp(
      ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
    );
  }

  ThemeData getTheme(Brightness brightness) {
    var colorScheme = _scheme(brightness).toColorScheme(brightness);
    return ThemeData(
      useMaterial3: true,
      extensions: [this],
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.openSansTextTheme(),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.resolveWith(
            (states) => const TextStyle(fontSize: 18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.resolveWith(
            (states) => const TextStyle(fontSize: 18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.resolveWith(
            (states) => const TextStyle(fontSize: 18),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.5),
        thickness: 0.5,
        space: 0.5,
      ),
      dividerColor: colorScheme.outline.withOpacity(0.5),
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.background,
    );
  }

  Scheme _scheme(Brightness brightness) {
    final palette = CorePalette.of(primaryColor.value);
    if (brightness == Brightness.light) {
      return Scheme.lightFromCorePalette(palette);
    }
    return Scheme.darkFromCorePalette(palette);
  }
}

extension on Scheme {
  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: Color(primary),
      onPrimary: Color(onPrimary),
      primaryContainer: Color(primaryContainer),
      onPrimaryContainer: Color(onPrimaryContainer),
      secondary: Color(secondary),
      onSecondary: Color(onSecondary),
      secondaryContainer: Color(secondaryContainer),
      onSecondaryContainer: Color(onSecondaryContainer),
      tertiary: Color(tertiary),
      onTertiary: Color(onTertiary),
      tertiaryContainer: Color(tertiaryContainer),
      onTertiaryContainer: Color(onTertiaryContainer),
      error: Color(error),
      onError: Color(onError),
      errorContainer: Color(errorContainer),
      onErrorContainer: Color(onErrorContainer),
      background: Color(background),
      onBackground: Color(onBackground),
      surface: Color(surface),
      onSurface: Color(onSurface),
      surfaceVariant: Color(surfaceVariant),
      onSurfaceVariant: Color(onSurfaceVariant),
      outline: Color(outline),
      shadow: Color(shadow),
      inverseSurface: Color(inverseSurface),
      inversePrimary: Color(inversePrimary),
    );
  }
}

const List<Color> appColors = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.lime,
  Colors.lightGreen,
  Colors.green,
  Colors.lightBlue,
  Colors.blue,
  Colors.cyan,
  Colors.blueGrey,
  Colors.purple,
  Colors.pink,
];

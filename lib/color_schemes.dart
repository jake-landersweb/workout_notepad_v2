import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

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

  ThemeData getTheme(
      BuildContext context, Brightness brightness, DataModel dmodel) {
    var colorScheme = _scheme(brightness).toColorScheme(brightness);
    return ThemeData(
      useMaterial3: true,
      extensions: [this],
      brightness: brightness,
      canvasColor: AppColors.background(context),
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: dmodel.color,
            surface: AppColors.background(context),
            onPrimaryContainer: Colors.white,
          ),
      // textTheme: GoogleFonts.poppinsTextTheme(),
      textTheme: GoogleFonts.soraTextTheme(),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => dmodel.color,
          ),
          textStyle: WidgetStateProperty.resolveWith(
            (states) => const TextStyle(fontSize: 18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.resolveWith(
            (states) => const TextStyle(fontSize: 18),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => AppColors.cell(context),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.transparent;
          },
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => AppColors.divider(context),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.background(context),
        dividerColor: AppColors.divider(context),
        surfaceTintColor: Colors.transparent,
        headerForegroundColor: AppColors.text(context),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.resolveWith(
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
      primaryColor: dmodel.color,
      scaffoldBackgroundColor: AppColors.background(context),
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

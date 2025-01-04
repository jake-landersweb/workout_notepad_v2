import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_notepad_v2/color_schemes.dart';
import 'package:workout_notepad_v2/main.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/model/search_model.dart';
import 'package:workout_notepad_v2/views/workout_templates/workout_template_model.dart';

class Bootstrapper {
  final String? locale;

  const Bootstrapper._(this.locale);

  static Future<Bootstrapper> getInstance(String? locale) async {
    // do asynchronous initialization things here

    return Bootstrapper._(locale);
  }

  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataModel()),
        ChangeNotifierProvider(create: (context) => SearchModel()),
        ChangeNotifierProvider(create: (context) => WorkoutTemplateModel()),
      ],
      builder: (context, _) {
        var dmodel = Provider.of<DataModel>(context);
        final scheme = AppColorScheme(primaryColor: dmodel.color);
        return MaterialApp(
          title: "Workout Notepad Integration Test",
          debugShowCheckedModeBanner: false,
          theme: scheme.getTheme(context, Brightness.light, dmodel),
          onGenerateRoute: (settings) {
            return MaterialWithModalsPageRoute(
              settings: settings,
              builder: (context) => const Index(),
            );
          },
        );
      },
    );
  }
}

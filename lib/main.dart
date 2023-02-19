import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/color_schemes.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/home.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataModel()),
        ChangeNotifierProvider(create: (context) => LogicModel()),
      ],
      builder: (context, child) {
        return _body(context);
      },
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    final scheme = AppColorScheme(primaryColor: dmodel.color);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ThemeMode.system == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: MaterialApp(
        title: 'Workout Notepad',
        debugShowCheckedModeBanner: false,
        theme: scheme.getTheme(Brightness.light),
        darkTheme: scheme.getTheme(Brightness.dark),
        // theme: ThemeData(
        //   useMaterial3: true,
        //   primaryColor: dmodel.color.light.primary,
        //   textTheme: GoogleFonts.openSansTextTheme(),
        //   colorScheme: dmodel.color.light,
        // ),
        // darkTheme: ThemeData(
        //   useMaterial3: true,
        //   primaryColor: dmodel.color.dark.primary,
        //   textTheme: GoogleFonts.openSansTextTheme(),
        //   colorScheme: dmodel.color.dark,
        // ),
        onGenerateRoute: (settings) {
          return MaterialWithModalsPageRoute(
            settings: settings,
            builder: (context) => const Index(),
          );
        },
      ),
    );
  }
}

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    switch (dmodel.loadStatus) {
      case LoadStatus.init:
        return const CircularProgressIndicator();
      case LoadStatus.noUser:
        return const Text("NO USER");
      case LoadStatus.done:
        return const Home();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ThemeMode.system == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: MaterialApp(
        title: 'Workout Notepad',
        debugShowCheckedModeBanner: false,
        color: dmodel.color,
        theme: ThemeData(
          primarySwatch: dmodel.color,
          primaryColor: dmodel.color,
          brightness: Brightness.light,
          canvasColor: sui.CustomColors.lightList,
          scaffoldBackgroundColor: sui.CustomColors.lightList,
          backgroundColor: sui.CustomColors.lightList,
          cardColor: Colors.white,
          dividerColor: Colors.black.withOpacity(0.1),
          textTheme: GoogleFonts.openSansTextTheme(),
          colorScheme:
              const ColorScheme.light().copyWith(primary: dmodel.color),
        ),
        darkTheme: ThemeData(
          primarySwatch: dmodel.color,
          primaryColor: dmodel.color,
          brightness: Brightness.dark,
          canvasColor: sui.CustomColors.darkBG,
          scaffoldBackgroundColor: sui.CustomColors.darkBG,
          backgroundColor: sui.CustomColors.darkBG,
          cardColor: sui.CustomColors.darkList,
          dividerColor: Colors.white.withOpacity(0.1),
          textTheme: GoogleFonts.openSansTextTheme(),
          colorScheme: const ColorScheme.dark().copyWith(primary: dmodel.color),
        ),
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

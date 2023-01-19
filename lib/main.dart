import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:sapphireui/functions/root.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/home.dart';
import 'package:workout_notepad_v2/views/workouts/workouts_home.dart';

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
    return MaterialApp(
      title: 'Workout Notepad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: dmodel.color,
        scaffoldBackgroundColor: sui.CustomColors.backgroundColor(context),
        cardColor: sui.CustomColors.cellColor(context),
        textTheme: GoogleFonts.openSansTextTheme(),
      ),
      home: sui.CupertinoSheetBase(child: const Index()),
      // wrap entire app in curpertino sheet base
      builder: ((context, child) {
        return child ?? Container();
      }),
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

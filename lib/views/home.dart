import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/settings/settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var lmodel = Provider.of<LogicModel>(context);
    return Scaffold(
      body: [
        const WorkoutsHome(),
        const ExerciseHome(),
        Container(),
        const Settings(),
      ][lmodel.tabBarIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) => lmodel.setTabBarIndex(value),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: lmodel.tabBarIndex,
        destinations: const [
          NavigationDestination(
              icon: Icon(LineIcons.running), label: 'Workouts'),
          NavigationDestination(
              icon: Icon(LineIcons.dumbbell), label: 'Exercises'),
          NavigationDestination(icon: Icon(LineIcons.book), label: 'Logs'),
          NavigationDestination(icon: Icon(LineIcons.cog), label: 'Settings'),
        ],
      ),
    );
  }
}

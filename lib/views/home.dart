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
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _getView(lmodel, dmodel),
        comp.TabBar(
          index: lmodel.tabBarIndex.index,
          onItemTap: (context, index, item) {
            lmodel.setTabBarIndex(TabBarPage.values[index]);
          },
          builder: (context, index, item) {
            return Icon(
              item.child,
              size: 35,
              color: index == lmodel.tabBarIndex.index
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primaryContainer,
            );
          },
          items: [
            comp.TabBarItem(
              child: LineIcons.running,
              title: "Workouts",
            ),
            comp.TabBarItem(
              child: LineIcons.dumbbell,
              title: "Exercises",
            ),
            comp.TabBarItem(
              child: LineIcons.book,
              title: "Logs",
            ),
            comp.TabBarItem(
              child: LineIcons.cog,
              title: "Settings",
            ),
          ],
        ),
      ],
    );
  }

  Widget _getView(LogicModel lmodel, DataModel dmodel) {
    switch (lmodel.tabBarIndex) {
      case TabBarPage.workouts:
        return const WorkoutsHome();
      case TabBarPage.exercises:
        return const ExerciseHome();
      case TabBarPage.logs:
        return Container();
      case TabBarPage.settings:
        return const Settings();
    }
  }
}

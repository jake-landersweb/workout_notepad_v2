import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/views/root.dart';

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
          index: lmodel.tabBarIndex,
          onItemTap: (context, index, item) {
            lmodel.setTabBarIndex(index);
          },
          builder: (context, index, item) {
            return Icon(
              item.child,
              size: 35,
              color: index == lmodel.tabBarIndex ? dmodel.color : Colors.grey,
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
      case 0:
        return const Center(child: WorkoutsHome());
      case 1:
        return const Center(child: ExerciseHome());
      default:
        return Container();
    }
  }
}

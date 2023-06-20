import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/blurred_container.dart';
import 'package:workout_notepad_v2/components/clickable.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/settings/settings.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';
import 'package:workout_notepad_v2/views/workouts/logs/root.dart';

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
        _getBody(lmodel),
        _bar(context, lmodel, dmodel),
      ],
    );
  }

  Widget _getBody(LogicModel lmodel) {
    switch (lmodel.tabBarIndex) {
      case 0:
        return const WorkoutsHome();
      case 1:
        return const ExerciseHome();
      case 2:
        return const Settings();
      default:
        return Container();
    }
  }

  Widget _bar(BuildContext context, LogicModel lmodel, DataModel dmodel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 0.5,
          width: double.infinity,
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
        BlurredContainer(
          backgroundColor: Theme.of(context).colorScheme.background,
          opacity: 0.5,
          blur: 5,
          borderRadius: BorderRadius.circular(0),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                if (dmodel.workoutState != null)
                  Clickable(
                    onTap: () {
                      showMaterialModalBottomSheet(
                          context: context,
                          enableDrag: true,
                          builder: (context) {
                            return LaunchWorkout(state: dmodel.workoutState!);
                          });
                    },
                    child: BlurredContainer(
                      opacity: 0.5,
                      blur: 5,
                      borderRadius: BorderRadius.circular(0),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Current Workout",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer
                                          .withOpacity(0.5),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          dmodel.workoutState!.workout.title,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondaryContainer,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            LWTime(start: dmodel.workoutState!.startTime)
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _barRow(
                          context, lmodel, LineIcons.running, "Workouts", 0),
                      _barRow(
                          context, lmodel, LineIcons.dumbbell, "Exercises", 1),
                      _barRow(context, lmodel, LineIcons.cog, "Settings", 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _barRow(
    BuildContext context,
    LogicModel lmodel,
    IconData icon,
    String label,
    int index,
  ) {
    return Clickable(
      onTap: () {
        lmodel.setTabBarIndex(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: lmodel.tabBarIndex == index
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Icon(
            icon,
            color: lmodel.tabBarIndex == index
                ? Theme.of(context).colorScheme.onPrimary
                : null,
          ),
        ),
      ),
    );
  }
}

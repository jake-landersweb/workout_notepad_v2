import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import 'package:workout_notepad_v2/components/cancel_button.dart';

import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/utils/root.dart';

import 'package:workout_notepad_v2/views/workouts/launch/root.dart';

class LWReorder extends StatefulWidget {
  const LWReorder({super.key});

  @override
  State<LWReorder> createState() => _LWReorderState();
}

class _LWReorderState extends State<LWReorder> {
  @override
  Widget build(BuildContext context) {
    var lmodel = Provider.of<LaunchWorkoutModel>(context);
    return comp.HeaderBar.sheet(
      title: "Re-Order",
      leading: const [comp.CloseButton2()],
      trailing: const [CancelButton(title: "Done")],
      itemSpacing: 8,
      horizontalSpacing: 0,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: comp.RawReorderableList<WorkoutExercise>(
                  items: lmodel.state.exercises,
                  areItemsTheSame: (p0, p1) =>
                      p0.workoutExerciseId == p1.workoutExerciseId,
                  onReorderFinished: (item, from, to, newItems) {
                    var item1 = lmodel.state.exercises.removeAt(from);
                    lmodel.state.exercises.insert(to, item1);
                    var item2 = lmodel.state.exerciseChildren.removeAt(from);
                    lmodel.state.exerciseChildren.insert(to, item2);
                    var item3 = lmodel.state.exerciseLogs.removeAt(from);
                    lmodel.state.exerciseLogs.insert(to, item3);
                    var item4 = lmodel.state.exerciseChildLogs.removeAt(from);
                    lmodel.state.exerciseChildLogs.insert(to, item4);
                    setState(() {});
                  },
                  slideBuilder: (item, index) {
                    return ActionPane(
                      extentRatio: 0.3,
                      motion: const DrawerMotion(),
                      children: [
                        Expanded(
                          child: Row(children: [
                            SlidableAction(
                              onPressed: (context) async {
                                await Future.delayed(
                                  const Duration(milliseconds: 100),
                                );
                                setState(() {
                                  lmodel.removeExercise(context, index);
                                });
                              },
                              icon: LineIcons.alternateTrash,
                              label: "Delete",
                              foregroundColor:
                                  Theme.of(context).colorScheme.onError,
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          ]),
                        ),
                      ],
                    );
                  },
                  builder: (item, index, handle, inDrag) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: inDrag
                              ? AppColors.cell(context)[100]
                              : AppColors.cell(context),
                          borderRadius: BorderRadius.only(
                              topLeft: index == 0
                                  ? const Radius.circular(10)
                                  : const Radius.circular(0),
                              bottomLeft:
                                  index == lmodel.state.exercises.length - 1
                                      ? const Radius.circular(10)
                                      : const Radius.circular(0)),
                        ),
                        child: _itemCell(context, item, handle),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemCell(
    BuildContext context,
    WorkoutExercise item,
    Handle handle,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(item.title, style: ttLabel(context)),
          ),
          handle,
        ],
      ),
    );
  }
}

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/components/section.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';

class LWConfigureExercise extends StatefulWidget {
  const LWConfigureExercise({
    super.key,
    required this.index,
    required this.onCompletion,
  });
  final int index;
  final Function(List<ExerciseSet> sets) onCompletion;

  @override
  State<LWConfigureExercise> createState() => _LWConfigureExerciseState();
}

class _LWConfigureExerciseState extends State<LWConfigureExercise> {
  late List<ExerciseSet> _sets;

  @override
  void initState() {
    _sets = [
      for (var i in context
          .read<LaunchWorkoutModel>()
          .state
          .exerciseChildren[widget.index])
        i.copy(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var lmodel = Provider.of<LaunchWorkoutModel>(context);
    return comp.HeaderBar.sheet(
      title: "Configure Exercise",
      leading: const [comp.CloseButton()],
      trailing: [
        Clickable(
          onTap: () {
            widget.onCompletion(_sets);
            Navigator.of(context).pop();
          },
          child: Text(
            "Save",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
      itemSpacing: 8,
      horizontalSpacing: 0,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: comp.Section(
            "Super Sets",
            headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: comp.RawReorderableList<ExerciseSet>(
                    items: _sets,
                    areItemsTheSame: (p0, p1) => p0.childId == p1.childId,
                    onReorderFinished: (item, from, to, newItems) {
                      setState(() {
                        _sets = newItems;
                      });
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
                                    _sets.removeAt(index);
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
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                                topLeft: index == 0
                                    ? const Radius.circular(10)
                                    : const Radius.circular(0),
                                bottomLeft: index == _sets.length - 1
                                    ? const Radius.circular(10)
                                    : const Radius.circular(0)),
                          ),
                          child: ExerciseCell(
                            exercise: item,
                            padding: EdgeInsets.zero,
                            showBackground: false,
                            trailingWidget: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: handle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    cupertinoSheet(
                      context: context,
                      builder: (context) => SelectExercise(
                        onSelect: (exercise) {
                          // create exercise set
                          var set = ExerciseSet.fromExercise(
                            lmodel.state.workout.workoutId,
                            lmodel.state.exercises[widget.index],
                            exercise,
                          );
                          setState(() {
                            _sets.add(set);
                          });
                        },
                      ),
                    );
                  },
                  child: const Text("Add Super-Set"),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

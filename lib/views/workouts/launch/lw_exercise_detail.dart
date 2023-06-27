import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/cell_wrapper.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/floating_sheet.dart';
import 'package:workout_notepad_v2/components/time_picker.dart';
import 'package:workout_notepad_v2/components/timer.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';

class LWExerciseDetail extends StatefulWidget {
  const LWExerciseDetail({
    super.key,
    required this.index,
  });
  final int index;

  @override
  State<LWExerciseDetail> createState() => _LWExerciseDetailState();
}

class _LWExerciseDetailState extends State<LWExerciseDetail> {
  @override
  Widget build(BuildContext context) {
    var lmodel = Provider.of<LaunchWorkoutModel>(context);
    return SingleChildScrollView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // exercise utils
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      _actionCell(
                        context,
                        "Configure",
                        Icons.settings_outlined,
                        () {
                          cupertinoSheet(
                            context: context,
                            builder: (context) => LWConfigureExercise(
                              index: widget.index,
                              onCompletion: (sets) {
                                lmodel.handleSuperSets(widget.index, sets);
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _actionCell(context, "Swap", LineIcons.syncIcon, () {
                        cupertinoSheet(
                          context: context,
                          builder: (context) => SelectExercise(
                            title: "Swap Exercise",
                            onSelect: (exercise) {
                              lmodel.addExercise(exercise, widget.index);
                            },
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      _actionCell(context, "Add Next", Icons.new_label_outlined,
                          () {
                        cupertinoSheet(
                          context: context,
                          builder: (context) => SelectExercise(
                            title: "Add Exercise Next",
                            onSelect: (exercise) async {
                              lmodel.addExercise(
                                exercise,
                                widget.index + 1,
                                push: true,
                              );
                              await Future.delayed(
                                const Duration(milliseconds: 700),
                              );
                              lmodel.state.pageController.animateToPage(
                                widget.index + 1,
                                duration: const Duration(milliseconds: 500),
                                curve: Sprung.overDamped,
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                if (lmodel.state.exercises[widget.index].note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CellWrapper(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(LineIcons.infoCircle),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                  lmodel.state.exercises[widget.index].note,
                                  style: ttLabel(context)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                Text(
                  lmodel.state.exercises[widget.index].title,
                  style: ttSubTitle(context,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                if (lmodel.state.exercises[widget.index].description.isNotEmpty)
                  Text(
                    lmodel.state.exercises[widget.index].description,
                    style: ttBody(
                      context,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                const SizedBox(height: 8),
                _getCell(
                  context,
                  lmodel.state.exercises[widget.index],
                  lmodel.state.exerciseLogs[widget.index],
                  lmodel,
                ),
              ],
            ),
          ),
          if (lmodel.state.exerciseChildLogs[widget.index].isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 0.5,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "SUPER-SET",
                      style: ttBody(
                        context,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 0.5,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          for (int i = 0;
              i < lmodel.state.exerciseChildLogs[widget.index].length;
              i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lmodel.state.exerciseChildren[widget.index][i].title,
                    style: ttSubTitle(
                      context,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (lmodel.state.exerciseChildren[widget.index][i].description
                      .isNotEmpty)
                    Text(
                      lmodel
                          .state.exerciseChildren[widget.index][i].description,
                      style: ttBody(
                        context,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: _getChildCell(
                      context,
                      i,
                      lmodel.state.exerciseChildLogs[widget.index][i],
                      lmodel,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _getCell(
    BuildContext context,
    ExerciseBase eb,
    ExerciseLog e,
    LaunchWorkoutModel lmodel,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (e.type == ExerciseType.timed)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: comp.CountdownTimer(
                duration: lmodel.state.exercises[widget.index].getDuration(),
                beginTime: _getTimerInstance(lmodel)?.startTime,
                onStart: () {
                  setState(() {
                    lmodel.state.timerInstances.add(
                      TimerInstance(
                        index: widget.index,
                        startTime: DateTime.now(),
                      ),
                    );
                  });
                },
                onEnd: () {
                  setState(() {
                    lmodel.state.timerInstances.removeWhere(
                      (element) =>
                          element.index == widget.index &&
                          element.childIndex == null,
                    );
                  });
                },
                fontSize: 60,
              ),
            ),
          ),
        if (e.type == ExerciseType.duration)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: comp.CountupTimer(
              goalDuration: lmodel.state.exercises[widget.index].getDuration(),
              startTime: _getTimerInstance(lmodel)?.startTime,
              startOnInit: _getTimerInstance(lmodel) != null,
              onStart: () {
                setState(() {
                  lmodel.state.timerInstances.add(
                    TimerInstance(
                      index: widget.index,
                      startTime: DateTime.now(),
                    ),
                  );
                });
              },
              onFinish: (duration) {
                // remove timer object
                setState(() {
                  lmodel.state.timerInstances.removeWhere(
                    (element) =>
                        element.index == widget.index &&
                        element.childIndex == null,
                  );
                });

                int idx = lmodel.state.exerciseLogs[widget.index].metadata
                    .indexWhere((element) => !element.saved);
                if (idx == -1) return;
                lmodel.state.exerciseLogs[widget.index]
                    .setDuration(idx, duration);
                lmodel.setLogSaved(widget.index, idx, true);
              },
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _default(context, e, lmodel),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(),
                  ),
                  Clickable(
                    onTap: () => lmodel.addLogSet(widget.index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _default(
    BuildContext context,
    ExerciseLog e,
    LaunchWorkoutModel lmodel,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        ImplicitlyAnimatedList(
          items: e.metadata,
          shrinkWrap: true,
          insertDuration: const Duration(milliseconds: 500),
          removeDuration: const Duration(milliseconds: 700),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: ((context, animation, item, i) {
            return SizeFadeTransition(
              sizeFraction: 0.7,
              curve: Curves.fastOutSlowIn,
              animation: animation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _Cell(
                  index: i,
                  title: "SET ${i + 1}",
                  reps: item.reps,
                  weight: item.weight,
                  weightPost: e.weightPost,
                  time: item.time,
                  type: e.type,
                  saved: item.saved,
                  onRepsChange: (val) =>
                      lmodel.setLogReps(widget.index, i, val),
                  onWeightChange: (val) =>
                      lmodel.setLogWeight(widget.index, i, val),
                  onWeightPostChange: (val) =>
                      lmodel.setLogWeightPost(widget.index, val),
                  onTimeChange: (val) =>
                      lmodel.setLogTime(widget.index, i, val),
                  onSaved: (val) => lmodel.setLogSaved(widget.index, i, val),
                  onDelete: () => lmodel.removeLogSet(widget.index, i),
                ),
              ),
            );
          }),
          areItemsTheSame: ((oldItem, newItem) => oldItem.id == newItem.id),
        ),
      ],
    );
  }

  Widget _getChildCell(
    BuildContext context,
    int childIndex,
    ExerciseLog e,
    LaunchWorkoutModel lmodel,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (e.type == ExerciseType.timed)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: comp.CountdownTimer(
                duration: lmodel
                    .state.exerciseChildren[widget.index][childIndex]
                    .getDuration(),
                beginTime:
                    _getChildTimerInstance(lmodel, childIndex)?.startTime,
                onStart: () {
                  setState(() {
                    lmodel.state.timerInstances.add(
                      TimerInstance(
                        index: widget.index,
                        childIndex: childIndex,
                        startTime: DateTime.now(),
                      ),
                    );
                  });
                },
                onEnd: () {
                  setState(() {
                    lmodel.state.timerInstances.removeWhere(
                      (element) =>
                          element.index == widget.index &&
                          element.childIndex == childIndex,
                    );
                  });
                },
                fontSize: 60,
              ),
            ),
          ),
        if (e.type == ExerciseType.duration)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: comp.CountupTimer(
              goalDuration: lmodel
                  .state.exerciseChildren[widget.index][childIndex]
                  .getDuration(),
              startTime: _getChildTimerInstance(lmodel, childIndex)?.startTime,
              startOnInit: _getChildTimerInstance(lmodel, childIndex) != null,
              onStart: () {
                setState(() {
                  lmodel.state.timerInstances.add(
                    TimerInstance(
                      index: widget.index,
                      childIndex: childIndex,
                      startTime: DateTime.now(),
                    ),
                  );
                });
              },
              onFinish: (duration) {
                // remove timer object
                setState(() {
                  lmodel.state.timerInstances.removeWhere(
                    (element) =>
                        element.index == widget.index &&
                        element.childIndex == childIndex,
                  );
                });

                int idx = lmodel
                    .state.exerciseChildLogs[widget.index][childIndex].metadata
                    .indexWhere((element) => !element.saved);
                if (idx == -1) return;
                lmodel.state.exerciseChildLogs[widget.index][childIndex]
                    .setDuration(idx, duration);
                lmodel.setLogChildSaved(widget.index, childIndex, idx, true);
              },
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _child(context, childIndex, e, lmodel),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(),
                  ),
                  Clickable(
                    onTap: () =>
                        lmodel.addLogChildSet(widget.index, childIndex),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _child(
    BuildContext context,
    int childIndex,
    ExerciseLog e,
    LaunchWorkoutModel lmodel,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        ImplicitlyAnimatedList(
          items: e.metadata,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          insertDuration: const Duration(milliseconds: 500),
          removeDuration: const Duration(milliseconds: 700),
          itemBuilder: ((context, animation, item, i) {
            return SizeFadeTransition(
              sizeFraction: 0.7,
              curve: Curves.fastOutSlowIn,
              animation: animation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _Cell(
                  index: i,
                  title: "SET ${i + 1}",
                  reps: item.reps,
                  weight: item.weight,
                  weightPost: e.weightPost,
                  time: item.time,
                  type: e.type,
                  saved: item.saved,
                  onRepsChange: (val) =>
                      lmodel.setLogChildReps(widget.index, childIndex, i, val),
                  onWeightChange: (val) => lmodel.setLogChildWeight(
                      widget.index, childIndex, i, val),
                  onWeightPostChange: (val) => lmodel.setLogChildWeightPost(
                      widget.index, childIndex, val),
                  onTimeChange: (val) =>
                      lmodel.setLogChildTime(widget.index, childIndex, i, val),
                  onSaved: (val) =>
                      lmodel.setLogChildSaved(widget.index, childIndex, i, val),
                  onDelete: () =>
                      lmodel.removeLogChildSet(widget.index, childIndex, i),
                ),
              ),
            );
          }),
          areItemsTheSame: ((oldItem, newItem) => oldItem.id == newItem.id),
        ),
      ],
    );
  }

  Widget _actionCell(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Clickable(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          height: 60,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.5),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  TimerInstance? _getTimerInstance(LaunchWorkoutModel lmodel) {
    try {
      var m = lmodel.state.timerInstances.firstWhere(
        (element) =>
            element.index == widget.index && element.childIndex == null,
      );
      return m;
    } catch (_) {
      return null;
    }
  }

  TimerInstance? _getChildTimerInstance(
      LaunchWorkoutModel lmodel, int childIndex) {
    try {
      var m = lmodel.state.timerInstances.firstWhere(
        (element) =>
            element.index == widget.index && element.childIndex == childIndex,
      );
      return m;
    } catch (_) {
      return null;
    }
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    super.key,
    required this.index,
    required this.title,
    required this.reps,
    required this.weight,
    required this.weightPost,
    required this.time,
    required this.type,
    required this.saved,
    required this.onRepsChange,
    required this.onWeightChange,
    required this.onWeightPostChange,
    required this.onTimeChange,
    required this.onSaved,
    required this.onDelete,
  });
  final int index;
  final String title;
  final int reps;
  final int weight;
  final String weightPost;
  final int time;
  final ExerciseType type;
  final bool saved;
  final Function(int val) onRepsChange;
  final Function(int val) onWeightChange;
  final Function(String val) onWeightPostChange;
  final Function(int val) onTimeChange;
  final Function(bool val) onSaved;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              title,
              style: ttBody(context,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        Clickable(
          onTap: () {
            showFloatingSheet(
              context: context,
              builder: (context) => _CellLog(
                index: index,
                reps: reps,
                weight: weight,
                weightPost: weightPost,
                time: time,
                type: type,
                onRepsChange: onRepsChange,
                onWeightChange: onWeightChange,
                onWeightPostChange: onWeightPostChange,
                onTimeChange: onTimeChange,
                onSaved: onSaved,
                onDelete: onDelete,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: saved
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.transparent,
              border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 30,
            width: 30,
            child: saved
                ? Center(
                    child: Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  )
                : null,
          ),
        ),
        Expanded(
          flex: 2,
          child: _post(context),
        ),
      ],
    );
  }

  Widget _post(BuildContext context) {
    switch (type) {
      case ExerciseType.weight:
        return Row(
          children: [
            Expanded(child: _itemCell(context, "REPS", reps.toString())),
            Text(
              "*",
              style: ttLabel(context,
                  color: Theme.of(context).colorScheme.onBackground),
            ),
            Expanded(
              child: _itemCell(
                context,
                weightPost.toUpperCase(),
                weight.toString(),
              ),
            ),
          ],
        );
      case ExerciseType.timed:
      case ExerciseType.duration:
        return Row(
          children: [
            Expanded(child: _itemCell(context, "", formatHHMMSS(time))),
          ],
        );
    }
  }

  Widget _itemCell(BuildContext context, String title, String item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          item,
          style: ttTitle(context,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _CellLog extends StatefulWidget {
  const _CellLog({
    super.key,
    required this.index,
    required this.reps,
    required this.weight,
    required this.weightPost,
    required this.time,
    required this.type,
    required this.onRepsChange,
    required this.onWeightChange,
    required this.onWeightPostChange,
    required this.onTimeChange,
    required this.onSaved,
    required this.onDelete,
  });
  final int index;
  final int reps;
  final int weight;
  final String weightPost;
  final int time;
  final ExerciseType type;
  final Function(int val) onRepsChange;
  final Function(int val) onWeightChange;
  final Function(String val) onWeightPostChange;
  final Function(int val) onTimeChange;
  final Function(bool val) onSaved;
  final VoidCallback onDelete;

  @override
  State<_CellLog> createState() => _CellLogState();
}

class _CellLogState extends State<_CellLog> {
  late int _reps;
  late int _weight;
  late String _weightPost;
  late int _time;
  late List<int> _timeItems;

  @override
  void initState() {
    _reps = widget.reps;
    _weight = widget.weight;
    _weightPost = widget.weightPost;
    _time = widget.time;
    _timeItems = formatHHMMSS(_time, truncate: false)
        .split(":")
        .map((e) => int.parse(e))
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Spacer(),
              comp.CloseButton(),
            ],
          ),
          const SizedBox(height: 16),
          _getContent(context),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(flex: 1, child: Container()),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          widget.onDelete();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Delete",
                          style: ttBody(
                            context,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          widget.onRepsChange(_reps);
                          widget.onWeightChange(_weight);
                          widget.onWeightPostChange(_weightPost);
                          widget.onTimeChange(_time);
                          widget.onSaved(true);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getContent(BuildContext context) {
    switch (widget.type) {
      case ExerciseType.weight:
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: EditableExerciseItemCell(
                initialValue: _reps,
                label: "REPS",
                onChanged: (val) {
                  setState(() {
                    _reps = val;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: _weightCell(context),
            ),
          ],
        );
      case ExerciseType.timed:
      case ExerciseType.duration:
        return Row(
          children: [
            Expanded(
              child: _timedCell(context),
            ),
          ],
        );
    }
  }

  Widget _timedCell(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TimePicker(
        hours: _timeItems[0],
        minutes: _timeItems[1],
        seconds: _timeItems[2],
        label: "TIME",
        onChanged: (val) {
          setState(() {
            _time = val;
          });
        },
      ),
    );
  }

  Widget _weightCell(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        comp.NumberPicker(
          minValue: 0,
          intialValue: _weight,
          textFontSize: 40,
          showPicker: true,
          maxValue: 99999,
          spacing: 8,
          onChanged: (val) {
            setState(() {
              _weight = val;
            });
          },
          picker: SizedBox(
            width: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  children: [
                    _buttonCell(context, "lbs"),
                    _buttonCell(context, "kg"),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            "WEIGHT",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttonCell(
    BuildContext context,
    String post,
  ) {
    return Expanded(
      child: Clickable(
        onTap: () {
          setState(() {
            _weightPost = post;
          });
        },
        child: Container(
          color: _weightPost == post
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          width: double.infinity,
          child: Center(
            child: Text(
              post.toUpperCase(),
              style: TextStyle(
                color: _weightPost == post
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight:
                    _weightPost == post ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

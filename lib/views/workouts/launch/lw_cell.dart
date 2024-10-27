import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/alert.dart';

import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/colored_cell.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/floating_sheet.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/components/section.dart';
import 'package:workout_notepad_v2/components/time_picker.dart';
import 'package:workout_notepad_v2/components/timer.dart';
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/select_exercise.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_model.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_time.dart';

class LWCell extends StatefulWidget {
  const LWCell({
    super.key,
    required this.i,
  });
  final int i;

  @override
  State<LWCell> createState() => _LWCellState();
}

class _LWCellState extends State<LWCell> {
  @override
  Widget build(BuildContext context) {
    var lmodel = Provider.of<LaunchWorkoutModel>(context);
    var dmodel = Provider.of<DataModel>(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (int j = 0; j < lmodel.state.exerciseLogs[widget.i].length; j++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _cell(context, lmodel, dmodel, j),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: WrappedButton(
            title: "Add Super-set",
            type: WrappedButtonType.standard,
            icon: Icons.add,
            onTap: () {
              cupertinoSheet(
                context: context,
                builder: (context) => SelectExercise(
                  title: "Add Super-set",
                  onSelect: (e) {
                    lmodel.addExercise(
                      widget.i,
                      lmodel.state.exercises[widget.i].length,
                      e,
                      dmodel.tags
                          .firstWhereOrNull((element) => element.isDefault),
                    );
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 60)
      ],
    );
  }

  Widget _cell(BuildContext context, LaunchWorkoutModel lmodel,
      DataModel dmodel, int j) {
    var e = lmodel.state.exercises[widget.i][j];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(e.title, style: ttSubTitle(context)),
        Section(
          e.title,
          allowsCollapse: true,
          initOpen: false,
          headerPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            children: [
              Row(
                children: [
                  _actionCell(
                    context,
                    Icons.info_outline,
                    "Details",
                    () {
                      cupertinoSheet(
                        context: context,
                        builder: (context) => ExerciseDetail(
                          showEdit: false,
                          exerciseId:
                              lmodel.state.exercises[widget.i][j].exerciseId,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _actionCell(
                    context,
                    Icons.bar_chart_rounded,
                    "Graphs",
                    () {
                      cupertinoSheet(
                        context: context,
                        builder: (context) => ExerciseLogs(
                          exerciseId:
                              lmodel.state.exercises[widget.i][j].exerciseId,
                          isInteractive: false,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _actionCell(
                    context,
                    Icons.cached_rounded,
                    "Swap Exercise",
                    () {
                      cupertinoSheet(
                        context: context,
                        builder: (context) => SelectExercise(
                          title: "Swap Exercise",
                          onSelect: (e) {
                            lmodel.addExercise(
                              widget.i,
                              j,
                              e,
                              dmodel.tags.firstWhereOrNull(
                                  (element) => element.isDefault),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _actionCell(
                    context,
                    Icons.delete_outline_outlined,
                    "Remove",
                    () async {
                      await showAlert(
                        context: context,
                        title: "Delete Exercise",
                        body: const Text(
                          "Are you sure? You can re-add this at any time.",
                        ),
                        cancelText: "Cancel",
                        onCancel: () {},
                        cancelBolded: true,
                        submitText: "Delete",
                        submitColor: Colors.red,
                        onSubmit: () async {
                          await lmodel.removeExercise(widget.i, j);
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (e.type == ExerciseType.duration)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: comp.CountdownTimer(
                key: ValueKey(e.workoutExerciseId),
                duration: e.getDuration(),
                beginTime: _getTimerInstance(lmodel, j)?.startTime,
                onStart: () {
                  setState(() {
                    lmodel.state.timerInstances.add(
                      TimerInstance(
                        workoutExerciseId: e.workoutExerciseId,
                        startTime: DateTime.now(),
                      ),
                    );
                  });
                },
                onEnd: () {
                  setState(() {
                    lmodel.state.timerInstances.removeWhere((element) =>
                        element.workoutExerciseId == e.workoutExerciseId);
                  });
                },
                fontSize: 60,
              ),
            ),
          ),
        if (e.type == ExerciseType.timed)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: comp.CountupTimer(
              key: ValueKey(e.workoutExerciseId),
              goalDuration: e.getDuration(),
              startTime: _getTimerInstance(lmodel, j)?.startTime,
              startOnInit: _getTimerInstance(lmodel, j) != null,
              onStart: () {
                setState(() {
                  lmodel.state.timerInstances.add(
                    TimerInstance(
                      workoutExerciseId: e.workoutExerciseId,
                      startTime: DateTime.now(),
                    ),
                  );
                });
              },
              onFinish: (duration) {
                // remove timer object
                setState(() {
                  lmodel.state.timerInstances.removeWhere((element) =>
                      element.workoutExerciseId == e.workoutExerciseId);
                });

                int idx = lmodel.state.exerciseLogs[widget.i][j].metadata
                    .indexWhere((element) => !element.saved);
                if (idx == -1) return;
                lmodel.state.exerciseLogs[widget.i][j]
                    .setDuration(idx, duration);
                lmodel.setSaved(widget.i, j, idx, true);
              },
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cell(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _default(context, lmodel, j),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(),
                        ),
                        Clickable(
                          onTap: () => lmodel.addSet(
                            widget.i,
                            j,
                            dmodel.tags.firstWhereOrNull(
                                (element) => element.isDefault),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.add,
                                color: AppColors.cell(context),
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
          ),
        ),
      ],
    );
  }

  Widget _actionCell(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Clickable(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.cell(context),
          ),
          padding: EdgeInsets.all(8),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon),
                const SizedBox(width: 4),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _default(
    BuildContext context,
    LaunchWorkoutModel lmodel,
    int j,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        ImplicitlyAnimatedList(
          key: ValueKey(lmodel.state.exercises[widget.i][j].workoutExerciseId),
          items: lmodel.state.exerciseLogs[widget.i][j].metadata,
          shrinkWrap: true,
          insertDuration: const Duration(milliseconds: 500),
          removeDuration: const Duration(milliseconds: 700),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: ((context, animation, item, i) {
            return SizeFadeTransition(
              sizeFraction: 0.7,
              curve: Curves.fastOutSlowIn,
              animation: animation,
              child: Column(
                children: [
                  _Cell(
                    index: i,
                    title: "SET ${i + 1}",
                    reps: item.reps,
                    weight: item.weight,
                    weightPost: item.weightPost,
                    time: item.time,
                    type: lmodel.state.exercises[widget.i][j].type,
                    saved: item.saved,
                    tags: item.tags,
                    onRepsChange: (val) => lmodel.setReps(widget.i, j, i, val),
                    onWeightChange: (val) =>
                        lmodel.setWeight(widget.i, j, i, val),
                    onWeightPostChange: (val) =>
                        lmodel.setWeightPost(widget.i, j, val),
                    onTimeChange: (val) => lmodel.setTime(widget.i, j, i, val),
                    onSaved: (val) => lmodel.setSaved(widget.i, j, i, val),
                    onDelete: () => lmodel.removeSet(widget.i, j, i),
                    onTagClick: (tag) => lmodel.onTagClick(widget.i, j, i, tag),
                  ),
                  SizedBox(
                    height: 32,
                    child: i <
                            lmodel.state.exerciseLogs[widget.i][j].metadata
                                    .length -
                                1
                        ? Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.divider(context),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: getTimeBetween(lmodel, j, i),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.divider(context),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ],
              ),
            );
          }),
          areItemsTheSame: ((oldItem, newItem) =>
              oldItem.exerciseLogMetaId == newItem.exerciseLogMetaId),
        ),
      ],
    );
  }

  Widget getTimeBetween(LaunchWorkoutModel lmodel, int j, int i) {
    try {
      if (i == lmodel.state.exerciseLogs[widget.i][j].metadata.length - 1) {
        return Container();
      }

      if (lmodel.state.exerciseLogs[widget.i][j].metadata[i].saved) {
        if (lmodel.state.exerciseLogs[widget.i][j].metadata[i + 1].saved) {
          return Text(
            lmodel.state.exerciseLogs[widget.i][j].metadata[i + 1]
                .savedDifference(lmodel
                    .state.exerciseLogs[widget.i][j].metadata[i].savedDate),
            style: ttcaption(context),
          );
        } else {
          return LWTime(
            start:
                lmodel.state.exerciseLogs[widget.i][j].metadata[i].savedDate!,
            style: ttcaption(context),
          );
        }
      }
      return Container();
    } catch (e) {
      // to allow for out-of-bounds index checks when animating
      return Container();
    }
  }

  TimerInstance? _getTimerInstance(LaunchWorkoutModel lmodel, int j) {
    var m = lmodel.state.timerInstances.firstWhereOrNull(
      (element) =>
          element.workoutExerciseId ==
          lmodel.state.exercises[widget.i][j].workoutExerciseId,
    );
    return m;
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.index,
    required this.title,
    required this.reps,
    required this.weight,
    required this.weightPost,
    required this.time,
    required this.type,
    required this.saved,
    required this.tags,
    required this.onRepsChange,
    required this.onWeightChange,
    required this.onWeightPostChange,
    required this.onTimeChange,
    required this.onSaved,
    required this.onDelete,
    required this.onTagClick,
  });
  final int index;
  final String title;
  final int reps;
  final int weight;
  final String weightPost;
  final int time;
  final ExerciseType type;
  final bool saved;
  final List<ExerciseLogMetaTag> tags;
  final Function(int val) onRepsChange;
  final Function(int val) onWeightChange;
  final Function(String val) onWeightPostChange;
  final Function(int val) onTimeChange;
  final Function(bool val) onSaved;
  final VoidCallback onDelete;
  final Function(Tag tag) onTagClick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Clickable(
          onTap: () {
            showFloatingSheet(
              context: context,
              builder: (context) => LaunchCellLog(
                index: index,
                reps: reps,
                weight: weight,
                weightPost: weightPost,
                time: time,
                type: type,
                tags: tags,
                onRepsChange: onRepsChange,
                onWeightChange: onWeightChange,
                onWeightPostChange: onWeightPostChange,
                onTimeChange: onTimeChange,
                onSaved: onSaved,
                onDelete: onDelete,
                onTagClick: onTagClick,
              ),
            );
          },
          child: Container(
            color: AppColors.cell(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: ttBody(context),
                        ),
                        if (tags.isNotEmpty && saved)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                for (var i in tags)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: ColorUtil.random(i.title),
                                      shape: BoxShape.circle,
                                    ),
                                    height: 10,
                                    width: 10,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: saved
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 30,
                  width: 30,
                  child: saved
                      ? Center(
                          child: Icon(
                            Icons.check,
                            color: AppColors.cell(context),
                          ),
                        )
                      : null,
                ),
                Expanded(
                  flex: 3,
                  child: _post(context),
                ),
              ],
            ),
          ),
        ),
        // if (tags.isNotEmpty && saved)
        //   Row(
        //     children: [
        //       Expanded(
        //         child: Padding(
        //           padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        //           child: Wrap(
        //             spacing: 4,
        //             runSpacing: 4,
        //             children: [
        //               for (var i in tags)
        //                 Container(
        //                   decoration: BoxDecoration(
        //                     color: ColorUtil.random(i.title),
        //                     shape: BoxShape.circle,
        //                   ),
        //                   height: 10,
        //                   width: 10,
        //                 ),
        //               // ColoredCell(
        //               //   isTag: true,
        //               //   size: ColoredCellSize.small,
        //               //   title: i.title,
        //               // ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
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
              style: ttLabel(context, color: AppColors.subtext(context)),
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
      case ExerciseType.bw:
        return Row(
          children: [
            Expanded(child: _itemCell(context, "REPS", reps.toString())),
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
          style: ttTitle(context),
        ),
        if (title != "")
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.subtext(context),
            ),
          ),
      ],
    );
  }
}

class LaunchCellLog extends StatefulWidget {
  const LaunchCellLog({
    super.key,
    required this.index,
    required this.reps,
    required this.weight,
    required this.weightPost,
    required this.time,
    required this.type,
    required this.tags,
    required this.onRepsChange,
    required this.onWeightChange,
    required this.onWeightPostChange,
    required this.onTimeChange,
    required this.onSaved,
    required this.onDelete,
    required this.onTagClick,
    this.interactive = true,
  });
  final int index;
  final int reps;
  final int weight;
  final String weightPost;
  final int time;
  final ExerciseType type;
  final List<ExerciseLogMetaTag> tags;
  final Function(int val) onRepsChange;
  final Function(int val) onWeightChange;
  final Function(String val) onWeightPostChange;
  final Function(int val) onTimeChange;
  final Function(bool val) onSaved;
  final VoidCallback onDelete;
  final Function(Tag tag) onTagClick;
  final bool interactive;

  @override
  State<LaunchCellLog> createState() => _LaunchCellLogState();
}

class _LaunchCellLogState extends State<LaunchCellLog> {
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
    var dmodel = Provider.of<DataModel>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.interactive)
            const Row(
              children: [
                Spacer(),
                comp.CloseButton2(),
              ],
            ),
          const SizedBox(height: 16),
          _getContent(context),
          const SizedBox(height: 16),
          Section(
            "Tags",
            allowsCollapse: widget.interactive,
            initOpen: true,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Clickable(
                //   onTap: () => setState(() {
                //     //
                //   }),
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: AppColors.cell(context),
                //       border: Border.all(color: AppColors.cell(context)),
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     height: 40,
                //     child: const Padding(
                //       padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                //       child: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [Icon(Icons.add)],
                //       ),
                //     ),
                //   ),
                // ),
                for (int i = 0; i < dmodel.tags.length; i++)
                  _tagCell(context, dmodel.tags[i]),
              ],
            ),
          ),
          if (widget.interactive)
            Column(
              children: [
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
                                  color: AppColors.subtext(context),
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
      case ExerciseType.bw:
        return Row(
          children: [
            Expanded(
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
          ],
        );
    }
  }

  Widget _timedCell(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context),
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
              color: Theme.of(context).colorScheme.primary,
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
              : AppColors.cell(context),
          width: double.infinity,
          child: Center(
            child: Text(
              post.toUpperCase(),
              style: TextStyle(
                color: _weightPost == post
                    ? Colors.white
                    : AppColors.text(context),
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

  Widget _tagCell(BuildContext context, Tag tag) {
    return Clickable(
      onTap: () => setState(() {
        widget.onTagClick(tag);
      }),
      child: Container(
        decoration: BoxDecoration(
          color: widget.tags.any((element) => element.tagId == tag.tagId)
              // ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              ? ColorUtil.random(tag.title).withOpacity(0.15)
              : AppColors.cell(context),
          border: Border.all(
            color: widget.tags.any((element) => element.tagId == tag.tagId)
                // ? Theme.of(context).colorScheme.primary
                ? ColorUtil.random(tag.title)
                : AppColors.cell(context),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        height: 40,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "#${tag.title}",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

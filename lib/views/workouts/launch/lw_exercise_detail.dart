import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:sapphireui/sapphireui.dart' as sui;
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
                if (lmodel.exercises[widget.index].note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: sui.CellWrapper(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(LineIcons.infoCircle),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(lmodel.exercises[widget.index].note,
                                  style: ttLabel(context)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                Text(
                  lmodel.exercises[widget.index].title,
                  style: ttSubTitle(context,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                if (lmodel.exercises[widget.index].description.isNotEmpty)
                  Text(
                    lmodel.exercises[widget.index].description,
                    style: ttBody(
                      context,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                const SizedBox(height: 8),
                _getCell(
                  context,
                  lmodel.exercises[widget.index],
                  lmodel.exerciseLogs[widget.index],
                  lmodel,
                ),
              ],
            ),
          ),
          if (lmodel.exerciseChildLogs[widget.index].isNotEmpty)
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
              i < lmodel.exerciseChildLogs[widget.index].length;
              i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lmodel.exerciseChildren[widget.index][i].title,
                    style: ttSubTitle(
                      context,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (lmodel
                      .exerciseChildren[widget.index][i].description.isNotEmpty)
                    Text(
                      lmodel.exerciseChildren[widget.index][i].description,
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
                      lmodel.exerciseChildLogs[widget.index][i],
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
        if (e.type == 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: comp.CountdownTimer(
                duration: lmodel.exercises[widget.index].getDuration(),
                fontSize: 60,
              ),
            ),
          ),
        if (e.type == 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: comp.CountupTimer(
              goalDuration: lmodel.exercises[widget.index].getDuration(),
              onFinish: (duration) {
                int idx = lmodel.exerciseLogs[widget.index].metadata
                    .indexWhere((element) => !element.saved);
                if (idx == -1) return;
                lmodel.exerciseLogs[widget.index].setDuration(idx, duration);
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
                  sui.Button(
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
                  timePost: e.timePost,
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
                  onTimePostChange: (val) =>
                      lmodel.setLogTimePost(widget.index, val),
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
        if (e.type == 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: comp.CountdownTimer(
                duration: lmodel.exerciseChildren[widget.index][childIndex]
                    .getDuration(),
                fontSize: 60,
              ),
            ),
          ),
        if (e.type == 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: comp.CountupTimer(
              goalDuration: lmodel.exerciseChildren[widget.index][childIndex]
                  .getDuration(),
              onFinish: (duration) {
                int idx = lmodel
                    .exerciseChildLogs[widget.index][childIndex].metadata
                    .indexWhere((element) => !element.saved);
                if (idx == -1) return;
                lmodel.exerciseChildLogs[widget.index][childIndex]
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
                  sui.Button(
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
                  timePost: e.timePost,
                  type: e.type,
                  saved: item.saved,
                  onRepsChange: (val) =>
                      lmodel.setLogChildReps(widget.index, childIndex, i, val),
                  onWeightChange: (val) => lmodel.setLogChildWeight(
                      widget.index, childIndex, i, val),
                  onWeightPostChange: (val) =>
                      lmodel.setLogChildTimePost(widget.index, childIndex, val),
                  onTimeChange: (val) =>
                      lmodel.setLogChildTime(widget.index, childIndex, i, val),
                  onTimePostChange: (val) =>
                      lmodel.setLogChildTimePost(widget.index, childIndex, val),
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
    required this.timePost,
    required this.type,
    required this.saved,
    required this.onRepsChange,
    required this.onWeightChange,
    required this.onWeightPostChange,
    required this.onTimeChange,
    required this.onTimePostChange,
    required this.onSaved,
    required this.onDelete,
  });
  final int index;
  final String title;
  final int reps;
  final int weight;
  final String weightPost;
  final int time;
  final String timePost;
  final int type;
  final bool saved;
  final Function(int val) onRepsChange;
  final Function(int val) onWeightChange;
  final Function(String val) onWeightPostChange;
  final Function(int val) onTimeChange;
  final Function(String val) onTimePostChange;
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
        sui.Button(
          onTap: () {
            sui.showFloatingSheet(
              context: context,
              builder: (context) => _CellLog(
                index: index,
                reps: reps,
                weight: weight,
                weightPost: weightPost,
                time: time,
                timePost: timePost,
                type: type,
                onRepsChange: onRepsChange,
                onWeightChange: onWeightChange,
                onWeightPostChange: onWeightPostChange,
                onTimeChange: onTimeChange,
                onTimePostChange: onTimePostChange,
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
      case 1:
      case 2:
        return Row(
          children: [
            Expanded(child: _itemCell(context, timePost.toUpperCase(), time)),
          ],
        );
      default:
        return Row(
          children: [
            Expanded(child: _itemCell(context, "REPS", reps)),
            Text(
              "*",
              style: ttLabel(context,
                  color: Theme.of(context).colorScheme.onBackground),
            ),
            Expanded(
              child: _itemCell(
                context,
                weightPost.toUpperCase(),
                weight,
              ),
            ),
          ],
        );
    }
  }

  Widget _itemCell(BuildContext context, String title, int item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          item.toString(),
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
    required this.timePost,
    required this.type,
    required this.onRepsChange,
    required this.onWeightChange,
    required this.onWeightPostChange,
    required this.onTimeChange,
    required this.onTimePostChange,
    required this.onSaved,
    required this.onDelete,
  });
  final int index;
  final int reps;
  final int weight;
  final String weightPost;
  final int time;
  final String timePost;
  final int type;
  final Function(int val) onRepsChange;
  final Function(int val) onWeightChange;
  final Function(String val) onWeightPostChange;
  final Function(int val) onTimeChange;
  final Function(String val) onTimePostChange;
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
  late String _timePost;

  @override
  void initState() {
    _reps = widget.reps;
    _weight = widget.weight;
    _weightPost = widget.weightPost;
    _time = widget.time;
    _timePost = widget.timePost;
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
                          widget.onTimePostChange(_timePost);
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
      case 1:
      case 2:
        return Row(
          children: [
            Expanded(
              child: _timedCell(context),
            ),
          ],
        );
      default:
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
    }
  }

  Widget _timedCell(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        comp.NumberPicker(
          minValue: 0,
          intialValue: _time,
          textFontSize: 40,
          showPicker: true,
          maxValue: 99999,
          spacing: 8,
          onChanged: (val) {
            setState(() {
              _time = val;
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
                    _buttonCell(context, "sec"),
                    _buttonCell(context, "min"),
                    _buttonCell(context, "hour"),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            "TIME",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
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
      child: sui.Button(
        onTap: () {
          if (widget.type == 1) {
            setState(() {
              _timePost = post;
            });
          } else {
            setState(() {
              _weightPost = post;
            });
          }
        },
        child: Container(
          color: _timePost == post || _weightPost == post
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.surfaceVariant,
          width: double.infinity,
          child: Center(
            child: Text(
              post.toUpperCase(),
              style: TextStyle(
                color: _timePost == post || _weightPost == post
                    ? Theme.of(context).colorScheme.onTertiary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: _timePost == post || _weightPost == post
                    ? FontWeight.w600
                    : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

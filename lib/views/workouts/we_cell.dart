import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/text_themes.dart';

class WECell extends StatefulWidget {
  const WECell({
    super.key,
    required this.workout,
    required this.exercise,
  });
  final Workout workout;
  final WorkoutExercise exercise;

  @override
  State<WECell> createState() => _WECellState();
}

class _WECellState extends State<WECell> {
  List<ExerciseSet> _children = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    _children = await widget.exercise.getChildren(widget.workout.workoutId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.exercise.title,
          style: ttLabel(context, color: dmodel.color),
        ),
        Text(
          "${widget.exercise.sets} x ${widget.exercise.reps}",
          style: ttBody(context),
        ),
        for (var i in _children)
          RichText(
            text: TextSpan(
              text: "- ",
              style: ttBody(context),
              children: [
                TextSpan(
                  text: i.title,
                  style: ttBody(
                    context,
                    color: dmodel.color,
                  ),
                ),
                TextSpan(
                  text: " (${i.sets} x ${i.reps})",
                  style: ttBody(
                    context,
                    color: sui.CustomColors.textColor(context).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

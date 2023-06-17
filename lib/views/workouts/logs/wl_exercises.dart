import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WLExercises extends StatefulWidget {
  const WLExercises({
    super.key,
    required this.workoutLog,
  });
  final WorkoutLog workoutLog;

  @override
  State<WLExercises> createState() => _WLExercisesState();
}

class _WLExercisesState extends State<WLExercises> {
  List<ExerciseLog>? _exerciseLogs;

  @override
  void initState() {
    _getChildren();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return sui.AppBar.sheet(
      title: "Exericse Logs",
      isFluid: true,
      leading: const [comp.CloseButton()],
      children: [
        if (_exerciseLogs != null)
          for (var i = 0; i < _exerciseLogs!.length; i++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _exerciseLogs![i].title,
                  style: ttSubTitle(
                    context,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                ELCell(
                  log: _exerciseLogs![i],
                  showDate: false,
                ),
              ],
            ),
      ],
    );
  }

  Future<void> _getChildren() async {
    _exerciseLogs = await widget.workoutLog.getExercises();
    setState(() {});
  }
}

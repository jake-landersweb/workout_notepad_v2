import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class LogsHome extends StatefulWidget {
  const LogsHome({super.key});

  @override
  State<LogsHome> createState() => _LogsHomeState();
}

class _LogsHomeState extends State<LogsHome> {
  List<Exercise> _recents = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // TODO--
    // _recents = await ExerciseLog.getMostRecentLogsExercise();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: "Recently Logged",
      isLarge: true,
      children: [
        const SizedBox(height: 16),
        for (var i in _recents)
          ExerciseCell(
            exercise: i,
            onTap: () {
              cupertinoSheet(
                context: context,
                builder: (context) => ExerciseDetail(exercise: i),
              );
            },
          ),
        const SizedBox(height: 50),
      ],
    );
  }
}

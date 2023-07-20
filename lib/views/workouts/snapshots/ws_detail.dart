import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_notepad_v2/components/cancel_button.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/data/workout_snapshot.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/workouts/workout_exercise_cell.dart';

class WorkoutSnapshotDetail extends StatefulWidget {
  const WorkoutSnapshotDetail({
    super.key,
    required this.snapshot,
  });
  final WorkoutSnapshot snapshot;

  @override
  State<WorkoutSnapshotDetail> createState() => _WorkoutSnapshotDetailState();
}

class _WorkoutSnapshotDetailState extends State<WorkoutSnapshotDetail> {
  late WorkoutCloneObject _snp;

  @override
  void initState() {
    _snp = widget.snapshot.renderSnapshot();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: DateFormat('yyyy, MMMM d').format(
        DateTime.fromMillisecondsSinceEpoch(widget.snapshot.createdEpoch),
      ),
      leading: const [BackButton2()],
      children: [
        const SizedBox(height: 16),
        for (var i in _snp.exercises)
          WorkoutExerciseCell(
            workoutId: widget.snapshot.workoutId,
            exercise: i.v1,
            children: i.v2,
          ),
      ],
    );
  }
}

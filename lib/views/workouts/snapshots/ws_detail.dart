import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/data/workout_snapshot.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

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
        for (int i = 0; i < _snp.exercises.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cell(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    for (int j = 0; j < _snp.exercises[i].length; j++)
                      Column(
                        children: [
                          ExerciseCell(
                            exercise: _snp.exercises[i][j],
                            padding: EdgeInsets.zero,
                            showBackground: false,
                          ),
                          if (j < _snp.exercises[i].length - 1)
                            Container(
                              color: AppColors.divider(context),
                              height: 1,
                              width: double.infinity,
                            ),
                        ],
                      ),
                  ],
                )),
          )
      ],
    );
  }
}

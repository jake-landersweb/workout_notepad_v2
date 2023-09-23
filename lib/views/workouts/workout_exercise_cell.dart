import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/root.dart';

class WorkoutExerciseCell extends StatefulWidget {
  const WorkoutExerciseCell({
    super.key,
    required this.workoutId,
    required this.exercise,
  });

  final String workoutId;
  final WorkoutExercise exercise;

  @override
  State<WorkoutExerciseCell> createState() => _WorkoutExerciseCellState();
}

class _WorkoutExerciseCellState extends State<WorkoutExerciseCell> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _getBody(context),
    );
  }

  Widget _getBody(BuildContext context) {
    return Placeholder();
    // if (_children.isEmpty) {
    //   return ExerciseCell(
    //     exercise: widget.exercise,
    //     padding: EdgeInsets.zero,
    //   );
    // } else {
    //   return Container(
    //     decoration: BoxDecoration(
    //       color: AppColors.cell(context)[200],
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //     child: Padding(
    //       padding: const EdgeInsets.all(4.0),
    //       child: Column(
    //         children: [
    //           Container(
    //             decoration: BoxDecoration(
    //               border: Border.all(color: AppColors.cell(context)[400]!),
    //               borderRadius: BorderRadius.circular(10),
    //             ),
    //             child: ExerciseCell(
    //               exercise: widget.exercise,
    //               padding: EdgeInsets.zero,
    //             ),
    //           ),
    //           for (var i in _children)
    //             Padding(
    //               padding: const EdgeInsets.only(top: 4.0),
    //               child: Container(
    //                 decoration: BoxDecoration(
    //                   border: Border.all(color: AppColors.cell(context)[400]!),
    //                   borderRadius: BorderRadius.circular(10),
    //                 ),
    //                 child: ExerciseCell(
    //                   exercise: i,
    //                   padding: EdgeInsets.zero,
    //                 ),
    //               ),
    //             ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
  }
}

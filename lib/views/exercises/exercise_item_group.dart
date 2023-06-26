import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/time_picker.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

import 'package:workout_notepad_v2/utils/root.dart';

class ExerciseItemGoup extends StatelessWidget {
  const ExerciseItemGoup({
    super.key,
    required this.exercise,
  });
  final ExerciseBase exercise;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ExerciseItemCell(
            label: "SETS",
            val: exercise.sets,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("x",
              style: ttLabel(context, color: Theme.of(context).primaryColor)),
        ),
        Expanded(
          child: _getSecond(context),
        ),
      ],
    );
  }

  Widget _getSecond(BuildContext context) {
    switch (exercise.type) {
      case ExerciseType.weight:
        return ExerciseItemCell(
          label: "REPS",
          val: exercise.reps,
        );
      case ExerciseType.timed:
      case ExerciseType.duration:
        return ExerciseItemCell(
          label: "TODO", // TODO
          val: exercise.getTime(),
        );
    }
  }
}

class EditableExerciseItemGroup extends StatefulWidget {
  const EditableExerciseItemGroup({
    super.key,
    required this.exercise,
    this.flex1 = 3,
    this.flex2 = 4,
    this.onChanged,
  });
  final ExerciseBase exercise;
  final int flex1;
  final int flex2;
  final VoidCallback? onChanged;

  @override
  State<EditableExerciseItemGroup> createState() =>
      _EditableExerciseItemGroupState();
}

class _EditableExerciseItemGroupState extends State<EditableExerciseItemGroup> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: widget.exercise.type == 0 ? 1 : widget.flex1,
          child: EditableExerciseItemCell(
            initialValue: widget.exercise.sets,
            label: "SETS",
            onChanged: (val) {
              setState(() {
                widget.exercise.sets = val;
              });
              if (widget.onChanged != null) {
                widget.onChanged!();
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("x",
              style: ttLabel(context, color: Theme.of(context).primaryColor)),
        ),
        Expanded(
          flex: widget.exercise.type == 0 ? 1 : widget.flex2,
          child: _getSecond(context),
        ),
      ],
    );
  }

  Widget _getSecond(BuildContext context) {
    switch (widget.exercise.type) {
      case ExerciseType.weight:
        return EditableExerciseItemCell(
          initialValue: widget.exercise.reps,
          label: "REPS",
          onChanged: (val) {
            setState(() {
              widget.exercise.reps = val;
            });
            if (widget.onChanged != null) {
              widget.onChanged!();
            }
          },
        );
      case ExerciseType.timed:
      case ExerciseType.duration:
        return _time(context, widget.exercise);
    }
  }

  Widget _time(BuildContext context, ExerciseBase e) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TimePicker(
        hours: e.getHours(),
        minutes: e.getMinutes(),
        seconds: e.getSeconds(),
        label: e.type == ExerciseType.timed ? "TIME" : "GOAL TIME",
        onChanged: (val) {
          setState(() {
            e.time = val;
          });
          if (widget.onChanged != null) {
            widget.onChanged!();
          }
        },
      ),
    );
  }

  // Widget _timeCell(
  //   BuildContext context,
  //   ExerciseBase e,
  //   String post,
  // ) {
  //   return Expanded(
  //     child: Clickable(
  //       showTap: false,
  //       onTap: () {
  //         setState(() {
  //           e.timePost = post;
  //         });
  //         if (widget.onChanged != null) {
  //           widget.onChanged!();
  //         }
  //       },
  //       child: Container(
  //         color: e.timePost == post
  //             ? Theme.of(context).colorScheme.primary
  //             : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
  //         width: double.infinity,
  //         child: Center(
  //           child: Text(
  //             post.toUpperCase(),
  //             style: TextStyle(
  //               color: e.timePost == post
  //                   ? Theme.of(context).colorScheme.onPrimary
  //                   : Theme.of(context).colorScheme.onSurface,
  //               fontWeight:
  //                   e.timePost == post ? FontWeight.w600 : FontWeight.w400,
  //               fontSize: 14,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

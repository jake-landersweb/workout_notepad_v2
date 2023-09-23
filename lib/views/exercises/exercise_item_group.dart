import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/time_picker.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';

import 'package:workout_notepad_v2/utils/root.dart';

class ExerciseItemGoup extends StatelessWidget {
  const ExerciseItemGoup({
    super.key,
    required this.exercise,
  });
  final Exercise exercise;

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
          child: Text("x", style: ttLabel(context)),
        ),
        Expanded(
          child: _getSecond(context),
        ),
      ],
    );
  }

  Widget _getSecond(BuildContext context) {
    switch (exercise.type) {
      case ExerciseType.bw:
      case ExerciseType.weight:
        return ExerciseItemCell(
          label: "REPS",
          val: exercise.reps,
        );
      case ExerciseType.timed:
      case ExerciseType.duration:
        return ExerciseItemCell(
          label: "TIME",
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
  final Exercise exercise;
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
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            flex:
                widget.exercise.type == ExerciseType.weight ? 1 : widget.flex1,
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
            flex:
                widget.exercise.type == ExerciseType.weight ? 1 : widget.flex2,
            child: _getSecond(context),
          ),
        ],
      ),
    );
  }

  Widget _getSecond(BuildContext context) {
    switch (widget.exercise.type) {
      case ExerciseType.bw:
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

  Widget _time(BuildContext context, Exercise e) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TimePicker(
                hours: e.getHours(),
                minutes: e.getMinutes(),
                seconds: e.getSeconds(),
                onChanged: (val) {
                  setState(() {
                    e.time = val;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!();
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              e.type == ExerciseType.timed ? "TIME" : "GOAL TIME",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
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
  //             : AppColors.cell(context),
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

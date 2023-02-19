import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:sapphireui/sapphireui.dart' as sui;
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
      case 1:
        return ExerciseItemCell(
          label: exercise.timePost.toUpperCase(),
          val: exercise.time,
        );
      default:
        return ExerciseItemCell(
          label: "REPS",
          val: exercise.reps,
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
          flex: widget.exercise.type == 1 ? widget.flex1 : 1,
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
          flex: widget.exercise.type == 1 ? widget.flex2 : 1,
          child: _getSecond(context),
        ),
      ],
    );
  }

  Widget _getSecond(BuildContext context) {
    switch (widget.exercise.type) {
      case 1:
        return _time(context, widget.exercise);
      default:
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
    }
  }

  Widget _time(BuildContext context, ExerciseBase e) {
    return comp.NumberPicker(
      minValue: 0,
      intialValue: e.time,
      textFontSize: 40,
      showPicker: true,
      maxValue: 99999,
      spacing: 8,
      onChanged: (val) {
        setState(() {
          e.time = val;
        });
        if (widget.onChanged != null) {
          widget.onChanged!();
        }
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
                _timeCell(context, e, "sec"),
                _timeCell(context, e, "min"),
                _timeCell(context, e, "hour"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeCell(
    BuildContext context,
    ExerciseBase e,
    String post,
  ) {
    return Expanded(
      child: sui.Button(
        onTap: () {
          setState(() {
            e.timePost = post;
          });
          if (widget.onChanged != null) {
            widget.onChanged!();
          }
        },
        child: Container(
          color: e.timePost == post
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.tertiaryContainer,
          width: double.infinity,
          child: Center(
            child: Text(
              post.toUpperCase(),
              style: TextStyle(
                color: e.timePost == post
                    ? Theme.of(context).colorScheme.onTertiary
                    : Theme.of(context).colorScheme.onTertiaryContainer,
                fontWeight:
                    e.timePost == post ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

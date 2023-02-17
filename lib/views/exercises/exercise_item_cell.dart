import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/exercise_base.dart';

class ExerciseItemCell extends StatefulWidget {
  const ExerciseItemCell({
    super.key,
    required this.initialValue,
    required this.label,
    required this.onChanged,
  });
  final int initialValue;
  final String label;
  final Function(int val) onChanged;

  @override
  State<ExerciseItemCell> createState() => _ExerciseItemCellState();
}

class _ExerciseItemCellState extends State<ExerciseItemCell> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        comp.NumberPicker(
          showPicker: false,
          textFontSize: 40,
          intialValue: widget.initialValue,
          onChanged: (val) => widget.onChanged(val),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

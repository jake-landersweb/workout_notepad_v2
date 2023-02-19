import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

class ExerciseItemCell extends StatelessWidget {
  const ExerciseItemCell({
    super.key,
    required this.label,
    required this.val,
  });
  final String label;
  final int val;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              val.toString(),
              style: TextStyle(
                fontSize: 60,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            label,
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

class EditableExerciseItemCell extends StatefulWidget {
  const EditableExerciseItemCell({
    super.key,
    required this.initialValue,
    required this.label,
    required this.onChanged,
  });
  final int initialValue;
  final String label;
  final Function(int val) onChanged;

  @override
  State<EditableExerciseItemCell> createState() =>
      _EditableExerciseItemCellState();
}

class _EditableExerciseItemCellState extends State<EditableExerciseItemCell> {
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

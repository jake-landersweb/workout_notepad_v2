import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class ExerciseItemCell extends StatelessWidget {
  const ExerciseItemCell({
    super.key,
    required this.label,
    required this.val,
  });
  final String label;
  final dynamic val;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: AutoSizeText(
              val.toString(),
              maxFontSize: 60,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 60,
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

import 'package:flutter/material.dart';

import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class CEEType extends StatefulWidget {
  const CEEType({
    super.key,
    required this.type,
    required this.onSelect,
    required this.isCreate,
  });
  final ExerciseType type;
  final Function(ExerciseType type) onSelect;
  final bool isCreate;

  @override
  State<CEEType> createState() => _CEETypeState();
}

class _CEETypeState extends State<CEEType> {
  late ExerciseType _type;

  @override
  void initState() {
    _type = widget.type;
    super.initState();
  }

  List<ExerciseType> _getValues() {
    var values = ExerciseType.values;
    if (widget.isCreate) {
      return values;
    } else {
      switch (_type) {
        case ExerciseType.bw:
        case ExerciseType.weight:
          return [ExerciseType.weight, ExerciseType.bw];
        case ExerciseType.timed:
        case ExerciseType.duration:
          return [ExerciseType.duration, ExerciseType.timed];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Exercise Type",
      trailing: const [CancelButton(title: "Done")],
      children: [
        const SizedBox(height: 16),
        for (var i in _getValues())
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _typeCell(context, i),
          ),
      ],
    );
  }

  Widget _typeCell(BuildContext context, ExerciseType type) {
    return Clickable(
      onTap: () {
        setState(() {
          _type = type;
        });
        widget.onSelect(type);
        Navigator.of(context).pop();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cell(context),
          border: Border.all(
            color: _type == type
                ? Theme.of(context).colorScheme.primary
                : AppColors.cell(context),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.asset(
                exerciseTypeIcon(type),
                height: 60,
                width: 60,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exerciseTypeTitle(type), style: ttSubTitle(context)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exerciseTypeDesc(type),
                            style: ttBody(
                              context,
                              color: AppColors.subtext(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

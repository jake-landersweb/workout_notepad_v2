import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/contained_list.dart';
import 'package:workout_notepad_v2/components/sheet_selector.dart';
import 'package:workout_notepad_v2/components/field.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';

import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/components/time_picker.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/exercises/create_edit_exercise/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';

class CEEType extends StatefulWidget {
  const CEEType({
    super.key,
    required this.type,
    required this.onSelect,
  });
  final ExerciseType type;
  final Function(ExerciseType type) onSelect;

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

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Exercise Type",
      trailing: const [CancelButton(title: "Done")],
      children: [
        const SizedBox(height: 16),
        for (var i in ExerciseType.values)
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/contained_list.dart';
import 'package:workout_notepad_v2/components/field.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';

import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/components/time_picker.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/image.dart';
import 'package:workout_notepad_v2/views/exercises/create_edit_exercise/cee_type.dart';
import 'package:workout_notepad_v2/views/exercises/create_edit_exercise/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';

class CEEDetails extends StatefulWidget {
  const CEEDetails({
    super.key,
    required this.cemodel,
  });
  final CreateExerciseModel cemodel;

  @override
  State<CEEDetails> createState() => _CEEDetailsState();
}

class _CEEDetailsState extends State<CEEDetails> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) => _body(context),
        );
      },
    );
  }

  Widget _body(BuildContext context) {
    return HeaderBar.sheet(
      title: "Details",
      trailing: const [
        CancelButton(
          title: "Done",
          useRoot: true,
        )
      ],
      children: [
        // image or video
        Section(
          "Asset",
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: _getAssetWidget(context),
                ),
              ),
              if (widget.cemodel.image != null || widget.cemodel.video != null)
                Clickable(
                  onTap: () {
                    setState(() {
                      widget.cemodel.image = null;
                      widget.cemodel.video = null;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cell(context),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
        // description (this should be step by step instructions)
        Section(
          "Description",
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cell(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Field(
                value: widget.cemodel.exerciseDetail.description,
                labelText:
                    "Break down the exercise into steps to make it easier to follow.",
                onChanged: (v) {
                  setState(() {
                    widget.cemodel.exerciseDetail.description = v;
                  });
                },
                isLabeled: false,
                maxLines: 5,
                minLines: 5,
              ),
            ),
          ),
        ),
        // Difficulty Level: Classify the exercise based on difficulty - beginner, intermediate, or advanced. This would help users in choosing exercises based on their fitness level.
        Section(
          "Difficulty",
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cell(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Field(
                value: widget.cemodel.exerciseDetail.difficultyLevel,
                labelText: "Beginner | Intermediate | Advanced",
                onChanged: (v) {
                  setState(() {
                    widget.cemodel.exerciseDetail.difficultyLevel = v;
                  });
                },
                isLabeled: false,
              ),
            ),
          ),
        ),
        // quipment Needed: Specify the equipment required to perform the exercise, such as dumbbells, resistance bands, pull-up bars, etc.
        Section(
          "Equipment Needed",
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cell(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Field(
                value: widget.cemodel.exerciseDetail.difficultyLevel,
                labelText: "Barbells, bands, free-weights, etc.",
                onChanged: (v) {
                  setState(() {
                    widget.cemodel.exerciseDetail.difficultyLevel = v;
                  });
                },
                isLabeled: false,
                maxLines: 3,
                minLines: 3,
              ),
            ),
          ),
        ),
        // Rest Time: Suggest an optimal rest time between sets based on the exercise's intensity.
        Section(
          "Rest Time",
          child: TimePicker(
            hours: widget.cemodel.exerciseDetail.getHours(),
            minutes: widget.cemodel.exerciseDetail.getMinutes(),
            seconds: widget.cemodel.exerciseDetail.getSeconds(),
            onChanged: (v) {
              setState(() {
                widget.cemodel.exerciseDetail.restTime = v;
              });
            },
          ),
        ),
        // Cues: These are reminders on form and technique during the exercise, e.g., "keep your back straight," "engage your core," etc.
        Section(
          "Cues",
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cell(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Field(
                value: widget.cemodel.exerciseDetail.cues,
                labelText:
                    "Reminders on form and technique, e.g., \"keep your back straight,\" \"engage your core,\" etc.",
                onChanged: (v) {
                  setState(() {
                    widget.cemodel.exerciseDetail.cues = v;
                  });
                },
                isLabeled: false,
                maxLines: 3,
                minLines: 3,
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }

  Widget _getAssetWidget(BuildContext context) {
    if (widget.cemodel.image != null) {
      return Image.file(
        widget.cemodel.image!,
        fit: BoxFit.fitHeight,
      );
    } else if (widget.cemodel.video != null) {
      return VideoRenderder(videoFile: widget.cemodel.video!);
    } else {
      return Clickable(
        onTap: () async {
          await promptMedia(context, "1234", (file) {
            if (file.v1 == null) {
              print("There was no selected file.");
            } else {
              switch (file.v2) {
                case PickedFileType.video:
                  setState(() {
                    widget.cemodel.image = null;
                    widget.cemodel.video = file.v1;
                  });
                  break;
                case PickedFileType.image:
                  setState(() {
                    widget.cemodel.video = null;
                    widget.cemodel.image = file.v1;
                  });
                  break;
              }
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose an Asset",
                  style: ttLabel(context),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

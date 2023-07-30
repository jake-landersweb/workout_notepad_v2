import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/image.dart';
import 'package:workout_notepad_v2/views/exercises/create_edit_exercise/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

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
              if (widget.cemodel.exerciseDetails.file.file != null)
                Clickable(
                  onTap: () {
                    setState(() {
                      widget.cemodel.exerciseDetails.file.deleteFile();
                    });
                    widget.cemodel.deleteFile = true;
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
                value: widget.cemodel.exerciseDetails.description,
                labelText:
                    "Break down the exercise into steps to make it easier to follow.",
                onChanged: (v) {
                  setState(() {
                    widget.cemodel.exerciseDetails.description = v;
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
                value: widget.cemodel.exerciseDetails.difficultyLevel,
                labelText: "Beginner | Intermediate | Advanced",
                onChanged: (v) {
                  setState(() {
                    widget.cemodel.exerciseDetails.difficultyLevel = v;
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
                value: widget.cemodel.exerciseDetails.equipmentNeeded,
                labelText: "Barbells, bands, free-weights, etc.",
                onChanged: (v) {
                  setState(() {
                    widget.cemodel.exerciseDetails.equipmentNeeded = v;
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
            hours: widget.cemodel.exerciseDetails.getHours(),
            minutes: widget.cemodel.exerciseDetails.getMinutes(),
            seconds: widget.cemodel.exerciseDetails.getSeconds(),
            onChanged: (v) {
              setState(() {
                widget.cemodel.exerciseDetails.restTime = v;
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
                value: widget.cemodel.exerciseDetails.cues,
                labelText:
                    "Reminders on form and technique, e.g., \"keep your back straight,\" \"engage your core,\" etc.",
                onChanged: (v) {
                  setState(() {
                    widget.cemodel.exerciseDetails.cues = v;
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
    if (widget.cemodel.exerciseDetails.file.file == null) {
      return Clickable(
        onTap: () async {
          await promptMedia(
            context: context,
            onSelected: (file) {
              if (file == null) {
                print("There was an issue picking the file");
              }
              setState(() {
                widget.cemodel.exerciseDetails.file.setFile(
                  objectId: widget.cemodel.fileObjectId,
                  file: file!,
                );
              });
            },
          );
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
    return widget.cemodel.exerciseDetails.file.getRenderer();
  }
}

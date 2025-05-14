import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/image.dart';
import 'package:workout_notepad_v2/views/exercises/create_edit_exercise/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/profile/paywall.dart';

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
    return _body(context);
  }

  Widget _body(BuildContext context) {
    return HeaderBar.sheet(
      title: "Details",
      trailing: const [
        CancelButton(
          title: "Done",
          useRoot: false,
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
              if (widget.cemodel.file.file != null)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Clickable(
                    onTap: () {
                      setState(() {
                        widget.cemodel.file.deleteFile();
                      });
                      widget.cemodel.deleteFile = true;
                      widget.cemodel.fileChanged = true;
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
                value: widget.cemodel.exercise.description,
                labelText:
                    "Break down the exercise into steps to make it easier to follow.",
                onChanged: (v) {
                  setState(() {
                    widget.cemodel.exercise.description = v;
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
                value: widget.cemodel.exercise.difficulty,
                labelText: "Beginner | Intermediate | Advanced",
                onChanged: (v) {
                  setState(() {
                    widget.cemodel.exercise.difficulty = v;
                  });
                },
                isLabeled: false,
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }

  Widget _getAssetWidget(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    if (widget.cemodel.file.file == null) {
      return Clickable(
        onTap: () async {
          if (!dmodel.hasValidSubscription()) {
            showPaywall(context);
          } else {
            await promptMedia(
              context: context,
              onSelected: (file) {
                if (file == null) {
                  print("There was an issue picking the file");
                }
                setState(() {
                  widget.cemodel.file.setFile(file: file!);
                });
              },
            );
          }
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: widget.cemodel.file.getRenderer(),
    );
  }
}

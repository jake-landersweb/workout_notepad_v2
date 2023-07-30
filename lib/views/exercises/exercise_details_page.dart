import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/cancel_button.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/loading_indicator.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_details.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/image.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

class ExerciseDetailsPage extends StatefulWidget {
  const ExerciseDetailsPage({
    super.key,
    required this.exerciseId,
  });
  final String exerciseId;

  @override
  State<ExerciseDetailsPage> createState() => _ExerciseDetailsPageState();
}

class _ExerciseDetailsPageState extends State<ExerciseDetailsPage> {
  ExerciseDetails? details;
  bool _isLoading = true;

  @override
  void initState() {
    _fetchDetails();
    super.initState();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
    });
    var db = await getDB();
    var response = await db.rawQuery(
      "SELECT * FROM exercise_detail WHERE exerciseId = '${widget.exerciseId}'",
    );
    if (response.isNotEmpty) {
      details = await ExerciseDetails.fromJson(response[0]);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Details",
      trailing: const [CancelButton(title: "Done")],
      children: [const SizedBox(height: 16), _child(context)],
    );
  }

  Widget _child(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: LoadingIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    } else if (details != null) {
      return Column(
        children: [
          if (details!.file.type != AppFileType.none)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 3,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: details!.file.getRenderer(),
                ),
              ),
            ),
          comp.Section(
            "Info",
            child: Column(
              children: [
                if (details!.description.isNotEmpty)
                  _detailWrapper(
                    context,
                    "Desc",
                    details!.description,
                  ),
                if (details!.difficultyLevel.isNotEmpty)
                  _detailWrapper(
                    context,
                    "Difficulty",
                    details!.difficultyLevel,
                  ),
                if (details!.equipmentNeeded.isNotEmpty)
                  _detailWrapper(
                    context,
                    "Equipment",
                    details!.equipmentNeeded,
                  ),
                // if (details!.restTime.isNotEmpty)
                //   _detailWrapper(context, "RestTime", details!.description),
                if (details!.cues.isNotEmpty)
                  _detailWrapper(
                    context,
                    "Cues",
                    details!.cues,
                  ),
              ],
            ),
          ),
        ],
      );
    } else {
      return const Center(
        child: Text(
          "There are no details for this exercise,",
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget _detailWrapper(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cell(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: comp.LabeledCell(
            label: label,
            child: Text(value),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/category_bubble.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ExerciseDetail extends StatefulWidget {
  const ExerciseDetail({
    super.key,
    required this.exercise,
  });
  final Exercise exercise;

  @override
  State<ExerciseDetail> createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _icon(context),
        const SizedBox(height: 16),
        _actions(context, dmodel),
        const SizedBox(height: 16),
        _details(context),
      ],
    );
  }

  Widget _icon(BuildContext context) {
    return getImageIcon(widget.exercise.icon, size: 100);
  }

  Widget _actions(BuildContext context, DataModel dmodel) {
    return Row(
      children: [
        Expanded(
          child: sui.Button(
            onTap: () {
              Navigator.of(context).pop();
              sui.showCupertinoSheet(
                context: context,
                builder: (context) => CEERoot(
                  isCreate: false,
                  exercise: widget.exercise,
                  onUpdate: () async {
                    await dmodel.refreshExercises();
                  },
                ),
              );
            },
            child: sui.CellWrapper(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Icon(LineIcons.edit, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 16),
                  Expanded(child: Text("Edit", style: ttBody(context))),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: sui.Button(
            onTap: () {
              // TODO: Implement
            },
            child: sui.CellWrapper(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Icon(LineIcons.plus, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 16),
                  Expanded(child: Text("Workout", style: ttBody(context))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _details(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        sui.ListView<Widget>(
          leadingPadding: 0,
          trailingPadding: 0,
          children: [
            if (widget.exercise.category.isNotEmpty)
              Text(widget.exercise.category.uppercase(),
                  style: ttBody(context)),
            if (widget.exercise.description?.isNotEmpty ?? false)
              Text(widget.exercise.description!, style: ttBody(context)),
            Text("${widget.exercise.sets} x ${widget.exercise.reps}",
                style: ttBody(context)),
          ],
        ),
      ],
    );
  }
}

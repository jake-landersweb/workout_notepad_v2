import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

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
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: sui.AppBar.sheet(
        title: widget.exercise.title,
        crossAxisAlignment: CrossAxisAlignment.center,
        leading: const [comp.CloseButton()],
        children: [
          if (widget.exercise.icon.isNotEmpty) _icon(context),
          const SizedBox(height: 16),
          _actions(context, dmodel),
          const SizedBox(height: 16),
          _details(context),
        ],
      ),
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
              comp.cupertinoSheet(
                context: context,
                builder: (context) => CEERoot(
                  isCreate: false,
                  exercise: widget.exercise,
                  onAction: (_) {
                    // close the detail screen
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
            child: sui.CellWrapper(
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              child: Row(
                children: [
                  Icon(LineIcons.edit,
                      color: Theme.of(context).colorScheme.tertiary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Edit",
                      style: ttBody(
                        context,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
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
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              child: Row(
                children: [
                  Icon(LineIcons.plus,
                      color: Theme.of(context).colorScheme.tertiary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Workout",
                      style: ttBody(
                        context,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
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
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            if (widget.exercise.category.isNotEmpty)
              sui.LabeledCell(
                label: "Category",
                child: Text(
                  widget.exercise.category.uppercase(),
                  style: ttLabel(context),
                ),
              ),
            if (widget.exercise.description.isNotEmpty)
              sui.LabeledCell(
                label: "Description",
                child:
                    Text(widget.exercise.description, style: ttLabel(context)),
              ),
            sui.LabeledCell(
              label: "",
              child: widget.exercise.info(context, style: ttLabel(context)),
            ),
            sui.Button(
              onTap: () async {
                showMaterialModalBottomSheet(
                  context: context,
                  enableDrag: false,
                  builder: (context) => ExerciseLogs(
                    exercise: widget.exercise,
                  ),
                );
              },
              child: sui.LabeledCell(
                label: "",
                child: Text("Logs", style: ttLabel(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

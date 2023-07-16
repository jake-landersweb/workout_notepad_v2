import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/launch_workout.dart';

class CollectionItemCell extends StatefulWidget {
  const CollectionItemCell({
    super.key,
    required this.item,
  });
  final CollectionItem item;

  @override
  State<CollectionItemCell> createState() => _CollectionItemCellState();
}

class _CollectionItemCellState extends State<CollectionItemCell> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.dateStr, style: ttcaption(context)),
            Text(
              widget.item.workout!.title,
              style: ttTitle(context),
            ),
            if (widget.item.collectionTitle != null)
              Text("Collection: ${widget.item.collectionTitle!}"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < widget.item.workout!.categories.length; i++)
                  CategoryCell(categoryId: widget.item.workout!.categories[i])
              ],
            ),
            const SizedBox(height: 16),
            WrappedButton(
              title: "Details",
              rowAxisSize: MainAxisSize.max,
              bg: AppColors.cell(context)[600],
              center: true,
              onTap: () {
                cupertinoSheet(
                  context: context,
                  builder: (context) => WorkoutDetail.small(
                    workout: widget.item.workout!,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            widget.item.workoutLogId == null
                ? WrappedButton(
                    bg: dmodel.workoutState?.workout.workoutId ==
                            widget.item.workout!.workoutId
                        ? AppColors.cell(context)[600]
                        : Theme.of(context).colorScheme.primary,
                    fg: dmodel.workoutState?.workout.workoutId ==
                            widget.item.workout!.workoutId
                        ? AppColors.text(context)
                        : Colors.white,
                    center: true,
                    rowAxisSize: MainAxisSize.max,
                    title: dmodel.workoutState?.workout.workoutId ==
                            widget.item.workout!.workoutId
                        ? "Resume"
                        : "Start",
                    onTap: () async => await launchWorkout(
                      context,
                      dmodel,
                      widget.item.workout!,
                      collectionItem: widget.item,
                    ),
                  )
                : WrappedButton(
                    title: "View Log",
                    type: WrappedButtonType.main,
                    center: true,
                    rowAxisSize: MainAxisSize.max,
                    onTap: () {},
                  ),
          ],
        ),
      ),
    );
  }
}

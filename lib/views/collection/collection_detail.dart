import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/collection/collection_progress_bar.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';

class CollectionDetail extends StatefulWidget {
  const CollectionDetail({
    super.key,
    required this.collection,
  });
  final Collection collection;

  @override
  State<CollectionDetail> createState() => _CollectionDetailState();
}

class _CollectionDetailState extends State<CollectionDetail> {
  @override
  Widget build(BuildContext context) {
    var dmodel = context.read<DataModel>();
    var nextItem = widget.collection.nextItem;
    return Scaffold(
      body: HeaderBar(
        title: widget.collection.title,
        isLarge: true,
        leading: const [BackButton2()],
        children: [
          const SizedBox(height: 16),
          CollectionProgressBar(
              collection: widget.collection, bg: Colors.black.withOpacity(0.1)),
          const SizedBox(height: 16),
          if (nextItem != null)
            Section(
              "Next - ${nextItem.dateStr}",
              child: WorkoutCellSmall(
                wc: nextItem.workout!,
                endWidget: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: WrappedButton(
                          title: "Details",
                          center: true,
                          bg: AppColors.cell(context)[500],
                          onTap: () {
                            cupertinoSheet(
                              context: context,
                              builder: (context) => WorkoutDetail.small(
                                workout: nextItem.workout!,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: WrappedButton(
                          bg: dmodel.workoutState?.workout.workoutId ==
                                  nextItem.workout!.workout.workoutId
                              ? AppColors.cell(context)[600]
                              : Theme.of(context).colorScheme.primary,
                          fg: dmodel.workoutState?.workout.workoutId ==
                                  nextItem.workout!.workout.workoutId
                              ? AppColors.text(context)
                              : Colors.white,
                          center: true,
                          title: dmodel.workoutState?.workout.workoutId ==
                                  nextItem.workout!.workout.workoutId
                              ? "Resume"
                              : "Start",
                          onTap: () async => await launchWorkout(
                            context,
                            dmodel,
                            nextItem.workout!.workout,
                            collectionItem: nextItem,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Section(
            "Completed",
            allowsCollapse: true,
            initOpen: false,
            child: ContainedList<CollectionItem>(
              children: widget.collection.items
                  .where((element) => element.workoutLogId != null)
                  .toList(),
              leadingPadding: 0,
              trailingPadding: 0,
              childBuilder: (context, item, index) => _itemCell(context, item),
            ),
          ),
          Section(
            "Todo",
            allowsCollapse: true,
            initOpen: true,
            child: ContainedList<CollectionItem>(
              children: widget.collection.items
                  .where((element) =>
                      element.workoutLogId == null &&
                      element.collectionItemId != nextItem?.collectionItemId)
                  .toList(),
              leadingPadding: 0,
              trailingPadding: 0,
              childBuilder: (context, item, index) => _itemCell(context, item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCell(BuildContext context, CollectionItem item) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.workout!.workout.title),
              Text(
                item.dateStr,
                style: TextStyle(
                  color: AppColors.subtext(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Clickable(
          onTap: () {
            showFloatingSheet(
              context: context,
              builder: (context) => Container(),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: item.workoutLogId != null
                  ? AppColors.cell(context)[600]
                  : Colors.transparent,
              border:
                  Border.all(color: AppColors.cell(context)[600]!, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 30,
            width: 30,
            child: item.workoutLogId != null
                ? Center(
                    child: Icon(
                      Icons.check,
                      color: AppColors.cell(context),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

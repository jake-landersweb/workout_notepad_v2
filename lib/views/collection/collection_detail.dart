import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/collection/collection_item_cell.dart';
import 'package:workout_notepad_v2/views/collection/collection_progress_bar.dart';
import 'package:workout_notepad_v2/views/workouts/logs/root.dart';

class CollectionDetail extends StatefulWidget {
  const CollectionDetail({
    super.key,
    required this.collection,
    required this.onStateChange,
  });
  final Collection collection;
  final VoidCallback onStateChange;

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
              "Next Workout",
              child: CollectionItemCell(item: nextItem),
            ),
          Section(
            "All",
            allowsCollapse: true,
            initOpen: true,
            child: ContainedList<CollectionItem>(
              children: widget.collection.items
                  .where((element) =>
                      element.collectionItemId != nextItem?.collectionItemId)
                  .toList(),
              leadingPadding: 0,
              trailingPadding: 0,
              childBuilder: (context, item, index) =>
                  _itemCell(context, dmodel, item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCell(
      BuildContext context, DataModel dmodel, CollectionItem item) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.workout!.title),
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
              builder: (context) => _CheckButton(
                collectionItem: item,
                onWorkoutLogSelect: (log) async {
                  item.workoutLogId = log.workoutLogId;
                  await item.insert(
                      conflictAlgorithm: ConflictAlgorithm.replace);
                  await dmodel.refreshCollections();
                  widget.onStateChange();
                  setState(() {});
                },
              ),
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

class _CheckButton extends StatefulWidget {
  const _CheckButton({
    super.key,
    required this.collectionItem,
    required this.onWorkoutLogSelect,
  });
  final CollectionItem collectionItem;
  final Function(WorkoutLog log) onWorkoutLogSelect;

  @override
  State<_CheckButton> createState() => __CheckButtonState();
}

class __CheckButtonState extends State<_CheckButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingSheet(
      title: "",
      child: Column(
        children: [
          ContainedList<Tuple4<String, IconData, Color, VoidCallback>>(
            childPadding: EdgeInsets.zero,
            leadingPadding: 0,
            trailingPadding: 0,
            children: [
              Tuple4(
                "Attach Previous Log",
                Icons.list_alt_rounded,
                Colors.deepPurple[600]!,
                () {
                  showMaterialModalBottomSheet(
                    context: context,
                    builder: (context) => WorkoutLogs(
                      workout: widget.collectionItem.workout!,
                      onSelect: (log) => widget.onWorkoutLogSelect(log),
                    ),
                  );
                },
              ),
              if (widget.collectionItem.workoutLogId != null)
                Tuple4(
                  "View Log",
                  Icons.article_rounded,
                  Colors.indigo,
                  () {
                    cupertinoSheet(
                      context: context,
                      builder: (context) => WLExercises(
                        workoutLogId: widget.collectionItem.workoutLogId!,
                      ),
                    );
                  },
                ),
            ],
            onChildTap: (context, item, index) {
              item.v4();
            },
            childBuilder: (context, item, index) {
              return WrappedButton(
                title: item.v1,
                icon: item.v2,
                iconBg: item.v3,
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/views/exercises/exercise_item_group.dart';
import 'package:workout_notepad_v2/views/exercises/select_exercise.dart';

class CEWGroupConfigure<T extends Exercise> extends StatelessWidget {
  const CEWGroupConfigure({
    super.key,
    required this.group,
    required this.onReorder,
    required this.removeExercise,
    required this.onAddToGroup,
    required this.sState,
  });
  final List<T> group;
  final void Function(List<T> group) onReorder;
  final void Function(int j) removeExercise;
  final void Function(int j, Exercise e) onAddToGroup;
  final VoidCallback sState;

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Configure",
      trailing: [
        CancelButton(
          title: "Done",
        )
      ],
      horizontalSpacing: 0,
      children: [
        RawReorderableList<T>(
          items: group,
          areItemsTheSame: (p0, p1) => p0.getUniqueId() == p1.getUniqueId(),
          header: const SizedBox(height: 16),
          footer: const SizedBox(height: 0),
          onReorderFinished: (item, from, to, newItems) {
            T movedSublist = group.removeAt(from);
            group.insert(to, movedSublist);
            onReorder(group);
          },
          slideBuilder: (item, index) {
            return ActionPane(
              extentRatio: 0.3,
              motion: const DrawerMotion(),
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        SlidableAction(
                          borderRadius: BorderRadius.circular(10),
                          onPressed: (context) async {
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                            removeExercise(index);
                          },
                          icon: Icons.delete,
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.error(),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          builder: (item, index, handle, inDrag) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: inDrag
                      ? AppColors.cell(context)[50]
                      : AppColors.cell(context),
                  border: Border.all(
                    color: AppColors.border(context),
                    width: 3,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: ttLabel(context)),
                            const SizedBox(height: 4),
                            EditableExerciseItemGroup(
                              exercise: item,
                              onChanged: () => sState,
                            ),
                          ],
                        ),
                      ),
                      handle
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 50),
          child: Clickable(
            onTap: () {
              cupertinoSheet(
                context: context,
                builder: (context) => SelectExercise(
                  onSelect: (e) {
                    onAddToGroup(group.length, e);
                  },
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.cell(context),
                border: Border.all(
                  color: AppColors.border(context),
                  width: 3,
                ),
              ),
              padding: EdgeInsets.all(8),
              child: Center(
                child: Text(
                  "Add Exercise",
                  style: ttLabel(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

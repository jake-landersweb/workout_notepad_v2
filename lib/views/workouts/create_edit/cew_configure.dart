import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/cew_group_configure.dart';

class CEWConfigure<T extends Exercise> extends StatelessWidget {
  const CEWConfigure({
    super.key,
    required this.exercises,
    required this.onReorderFinish,
    required this.removeAt,
    required this.onGroupReorder,
    required this.removeSuperset,
    required this.addExercise,
    required this.sState,
  });
  final List<List<T>> exercises;
  final void Function(List<List<T>> exercises) onReorderFinish;
  final void Function(int index) removeAt;

  // for groups
  final void Function(int i, List<T> group) onGroupReorder;
  final void Function(int i, int j) removeSuperset;
  final void Function(int index, Exercise e) addExercise;
  final VoidCallback sState;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return RawReorderableList<List<T>>(
      items: exercises,
      areItemsTheSame: (p0, p1) => p0[0].getUniqueId() == p1[0].getUniqueId(),
      header: const SizedBox(height: 8),
      footer: const SizedBox(height: 0),
      onReorderFinished: (item, from, to, newItems) {
        List<T> movedSublist = exercises.removeAt(from);
        exercises.insert(to, movedSublist);
        onReorderFinish(exercises);
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
                        removeAt(index);
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
          child: Clickable(
            onTap: () {
              cupertinoSheet(
                context: context,
                builder: (context) => CEWGroupConfigure<T>(
                  group: item,
                  onReorder: (List<T> group) {
                    onGroupReorder(index, group);
                  },
                  removeExercise: (int j) {
                    removeSuperset(index, j);
                  },
                  onAddToGroup: (int j, Exercise e) {
                    addExercise(index, e);
                  },
                  sState: () {},
                ),
              );
            },
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
                          for (var i in item)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.text(context)
                                          .withOpacity(0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    height: 6,
                                    width: 6,
                                  ),
                                  i.getIcon(dmodel.categories, size: 40),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text("${i.title}"),
                                          ),
                                        ],
                                      ),
                                      i.info(
                                        context,
                                        style: ttBody(
                                          context,
                                          color: AppColors.subtext(context),
                                        ),
                                      )
                                    ],
                                  )),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    handle,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

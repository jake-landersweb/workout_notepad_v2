import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/select_exercise.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/root.dart';

class CEWCell extends StatefulWidget {
  const CEWCell({
    super.key,
    required this.i,
  });
  final int i;

  @override
  State<CEWCell> createState() => _CEWCellState();
}

class _CEWCellState extends State<CEWCell> {
  @override
  Widget build(BuildContext context) {
    var cmodel = Provider.of<CEWModel>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
            ),
            child: RawReorderableList<Exercise>(
              items: cmodel.workout.getExercises()[widget.i],
              areItemsTheSame: (p0, p1) => p0.getUniqueId() == p1.getUniqueId(),
              header: const SizedBox(height: 0),
              footer: const SizedBox(height: 0),
              onReorderFinished: (item, from, to, newItems) {
                cmodel.refreshExercises(widget.i, newItems);
              },
              slideBuilder: (item, index) {
                return ActionPane(
                  extentRatio: 0.3,
                  motion: const DrawerMotion(),
                  children: [
                    Expanded(
                      child: Row(children: [
                        SlidableAction(
                          onPressed: (context) async {
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                            cmodel.removeSubExercise(widget.i, index);
                          },
                          icon: LineIcons.alternateTrash,
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.error(),
                        ),
                      ]),
                    ),
                  ],
                );
              },
              builder: (item, index, handle, inDrag) {
                return _cell(context, cmodel, index, item, handle, inDrag);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
            child: Clickable(
              onTap: () {
                cupertinoSheet(
                  context: context,
                  builder: (context) => SelectExercise(
                    title: "Add Super-set",
                    onSelect: (e) {
                      cmodel.addExercise(widget.i, e);
                    },
                  ),
                );
              },
              child: Container(
                color: AppColors.divider(context),
                width: double.infinity,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Text("Add Super-set"),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(
    BuildContext context,
    CEWModel cmodel,
    int j,
    Exercise item,
    Handle handle,
    bool inDrag,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: inDrag ? AppColors.cell(context)[50] : AppColors.cell(context),
          borderRadius: BorderRadius.only(
            topLeft: j == 0 ? const Radius.circular(10) : Radius.zero,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Row(
                children: [
                  Column(
                    children: [
                      handle,
                      const SizedBox(height: 4),
                      Clickable(
                        onTap: () {
                          showFloatingSheet(
                            context: context,
                            useRootNavigator: true,
                            builder: (context) => FloatingSheet(
                              title: "Configure",
                              child: Column(
                                children: [
                                  EditableExerciseItemGroup(
                                    exercise: item,
                                    onChanged: () => setState(() {}),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: Container()),
                                      Expanded(
                                        child: WrappedButton(
                                          title: "Done",
                                          center: true,
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          bg: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fg: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cell(context)[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            color: AppColors.cell(context)[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: ttLabel(context),
                              ),
                            ),
                          ],
                        ),
                        CategoryCell(
                          categoryId: item.category,
                        ),
                      ],
                    ),
                  ),
                  item.info(context),
                ],
              ),
            ),
            Container(
              color: AppColors.divider(context),
              width: double.infinity,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}

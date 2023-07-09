// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;

class CEWExerciseDetail extends StatefulWidget {
  const CEWExerciseDetail({
    super.key,
    required this.cewe,
    required this.index,
  });
  final CEWExercise cewe;
  final int index;

  @override
  State<CEWExerciseDetail> createState() => _CEWExerciseDetailState();
}

class _CEWExerciseDetailState extends State<CEWExerciseDetail> {
  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  Widget _body(BuildContext context) {
    var cmodel = Provider.of<CEWModel>(context);

    return comp.HeaderBar.sheet(
      title: "Configure",
      trailing: const [comp.CancelButton(title: "Done")],
      horizontalSpacing: 0,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: EditableExerciseItemGroup(
            exercise: widget.cewe.exercise,
            onChanged: () {
              cmodel.notifyListeners();
            },
          ),
        ),
        comp.Section(
          "Super Sets",
          headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: comp.RawReorderableList<ExerciseSet>(
                    items: widget.cewe.children,
                    areItemsTheSame: (p0, p1) => p0.childId == p1.childId,
                    onReorderFinished: (item, from, to, newItems) {
                      widget.cewe.children = newItems;
                      cmodel.notifyListeners();
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
                                    const Duration(milliseconds: 180),
                                  );
                                  cmodel.removeExerciseChild(
                                    widget.index,
                                    item,
                                  );
                                },
                                icon: LineIcons.alternateTrash,
                                label: "Delete",
                                foregroundColor:
                                    Theme.of(context).colorScheme.onError,
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            ]),
                          ),
                        ],
                      );
                    },
                    builder: (item, index, handle, inDrag) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: inDrag
                                ? AppColors.cell(context)[100]
                                : AppColors.cell(context),
                            borderRadius: BorderRadius.only(
                                topLeft: index == 0
                                    ? const Radius.circular(10)
                                    : const Radius.circular(0),
                                bottomLeft:
                                    index == widget.cewe.children.length - 1
                                        ? const Radius.circular(10)
                                        : const Radius.circular(0)),
                          ),
                          child: Row(
                            children: [
                              Clickable(
                                onTap: () {
                                  comp.showFloatingSheet(
                                    context: context,
                                    useRootNavigator: true,
                                    builder: (context) => comp.FloatingSheet(
                                      title: "",
                                      child: Column(
                                        children: [
                                          EditableExerciseItemGroup(
                                            exercise: item,
                                            onChanged: () =>
                                                cmodel.notifyListeners(),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(child: Container()),
                                              Expanded(
                                                child: comp.WrappedButton(
                                                  title: "Done",
                                                  center: true,
                                                  onTap: () =>
                                                      Navigator.of(context)
                                                          .pop(),
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
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 2, 0, 2),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.cell(context)[600],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.more_horiz_rounded,
                                        color: AppColors.subtext(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ExerciseCell(
                                  exercise: item,
                                  padding: EdgeInsets.zero,
                                  showBackground: false,
                                  trailingWidget: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: handle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                comp.WrappedButton(
                  title: "Add Super Set",
                  type: comp.WrappedButtonType.main,
                  onTap: () {
                    comp.cupertinoSheet(
                      context: context,
                      builder: (context) => SelectExercise(
                        selectedIds: cmodel.exercises[widget.index].children
                            .map((e) => e.childId)
                            .toList(),
                        onDeselect: (e) {
                          cmodel.exercises[widget.index].children.removeWhere(
                              (element) => element.childId == e.exerciseId);
                          cmodel.notifyListeners();
                        },
                        onSelect: (e) {
                          cmodel.addExerciseChild(
                            widget.index,
                            ExerciseSet.fromExercise(
                              cmodel.workout.workoutId,
                              widget.cewe.exercise,
                              e,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

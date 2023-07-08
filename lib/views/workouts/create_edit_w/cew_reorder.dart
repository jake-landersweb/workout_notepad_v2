import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class CEWReorder extends StatefulWidget {
  const CEWReorder({
    super.key,
    required this.cmodel,
  });
  final CEWModel cmodel;

  @override
  State<CEWReorder> createState() => _CEWReorderState();
}

class _CEWReorderState extends State<CEWReorder> {
  @override
  Widget build(BuildContext context) {
    return comp.HeaderBar.sheet(
      title: "Re-Order Exercises",
      horizontalSpacing: 0,
      leading: const [comp.CloseButton()],
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: comp.RawReorderableList<CEWExercise>(
              items: widget.cmodel.exercises,
              shrinkWrap: true,
              areItemsTheSame: (p0, p1) => p0.id == p1.id,
              onReorderFinished: (item, from, to, newItems) {
                widget.cmodel.refreshExercises(newItems);
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
                            widget.cmodel.removeExercise(index);
                          },
                          icon: LineIcons.alternateTrash,
                          label: "Delete",
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                          backgroundColor: Theme.of(context).colorScheme.error,
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
                              index == widget.cmodel.exercises.length - 1
                                  ? const Radius.circular(10)
                                  : const Radius.circular(0)),
                    ),
                    child: ExerciseCell(
                      exercise: item.exercise,
                      padding: EdgeInsets.zero,
                      showBackground: false,
                      trailingWidget: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: handle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

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
      title: "Configure Exercises",
      horizontalSpacing: 0,
      canScroll: false,
      trailing: const [comp.CancelButton(title: "Done")],
      children: [
        Expanded(
          child: comp.RawReorderableList<CEWExercise>(
            items: widget.cmodel.exercises,
            areItemsTheSame: (p0, p1) => p0.id == p1.id,
            header: const SizedBox(height: 75),
            footer: const SizedBox(height: 50),
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
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ]),
                  ),
                ],
              );
            },
            builder: (item, index, handle, inDrag) {
              return Container(
                decoration: BoxDecoration(
                  color: inDrag
                      ? AppColors.cell(context)[100]
                      : AppColors.cell(context),
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
              );
            },
          ),
        ),
      ],
    );
  }
}

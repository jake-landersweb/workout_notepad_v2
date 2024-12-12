import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/root.dart';

class CEWReorder extends StatefulWidget {
  const CEWReorder({super.key});

  @override
  State<CEWReorder> createState() => _CEWReorderState();
}

class _CEWReorderState extends State<CEWReorder> {
  @override
  Widget build(BuildContext context) {
    var cmodel = Provider.of<CEWModel>(context);
    return HeaderBar.sheet(
      title: "Re-Order",
      canScroll: false,
      trailing: const [CancelButton(title: "Done")],
      horizontalSpacing: 0,
      children: [
        RawReorderableList<List<Exercise>>(
          items: cmodel.workout.getExercises(),
          areItemsTheSame: (p0, p1) => p0.any((element) => p1.any(
              (element2) => element.getUniqueId() == element2.getUniqueId())),
          header: const SizedBox(height: 72),
          footer: const SizedBox(height: 0),
          onReorderFinished: (item, from, to, newItems) {
            cmodel.reorder(newItems);
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
                            cmodel.removeExercise(index);
                          },
                          icon: LineIcons.alternateTrash,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: inDrag
                      ? AppColors.cell(context)[50]
                      : AppColors.cell(context),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Row(
                      children: [
                        handle,
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i in item) Text("- ${i.title}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

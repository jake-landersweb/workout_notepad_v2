import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/collection/cec/root.dart';

class CECOrder extends StatefulWidget {
  const CECOrder({super.key});

  @override
  State<CECOrder> createState() => _CECOrderState();
}

class _CECOrderState extends State<CECOrder> {
  @override
  Widget build(BuildContext context) {
    var cmodel = context.read<CECModel>();
    return HeaderBar.sheet(
      title: "Re-Order",
      horizontalSpacing: 0,
      canScroll: false,
      trailing: const [CancelButton(title: "Done")],
      children: [
        Expanded(
          child: RawReorderableList<CollectionItem>(
            items: cmodel.collection.items,
            areItemsTheSame: (p0, p1) =>
                p0.collectionItemId == p1.collectionItemId,
            header: const SizedBox(height: 75),
            footer: const SizedBox(height: 50),
            onReorderFinished: (item, from, to, newItems) {
              cmodel.collection.items
                ..clear()
                ..addAll(newItems);
              setState(() {
                cmodel.refresh();
              });
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
                          cmodel.collection.items.removeWhere(
                            (element) =>
                                element.workoutId ==
                                item.workout!.workout.workoutId,
                          );
                          setState(() {
                            cmodel.refresh();
                          });
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.workout!.workout.title,
                          style: ttLabel(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: handle,
                      ),
                    ],
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

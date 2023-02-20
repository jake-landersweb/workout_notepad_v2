import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';
import 'package:workout_notepad_v2/views/root.dart';

class CEWRoot extends StatelessWidget {
  const CEWRoot({
    super.key,
    required this.isCreate,
    required this.onAction,
    this.workout,
  });
  final bool isCreate;
  final Workout? workout;
  final Function(Workout w) onAction;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider(
      create: (context) => isCreate
          ? CEWModel.create(dmodel.user!.userId)
          : CEWModel.update(workout!),
      builder: (context, _) => _CEW(
        isCreate: isCreate,
        onAction: onAction,
        workout: workout,
      ),
    );
  }
}

class _CEW extends StatefulWidget {
  const _CEW({
    super.key,
    required this.isCreate,
    required this.onAction,
    this.workout,
  });
  final bool isCreate;
  final Workout? workout;
  final Function(Workout w) onAction;

  @override
  State<_CEW> createState() => _CEWState();
}

class _CEWState extends State<_CEW> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var cmodel = Provider.of<CEWModel>(context);
    return comp.InteractiveSheet(
      header: ((context) => _header(context, dmodel, cmodel)),
      builder: (context) {
        return comp.RawReorderableList<CEWExercise>(
          items: cmodel.exercises,
          footer: AnimatedOpacity(
            opacity: cmodel.showExerciseButton ? 1 : 0,
            curve: Sprung(36),
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                  child: sui.Button(
                    onTap: () {
                      comp.cupertinoSheet(
                        context: context,
                        builder: (context) => SelectExercise(
                          onSelect: (e) {
                            cmodel.addExercise(WorkoutExercise.fromExercise(
                                cmodel.workout, e));
                          },
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          areItemsTheSame: (p0, p1) => p0.id == p1.id,
          onReorderFinished: (item, from, to, newItems) {
            cmodel.refreshExercises(newItems);
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
                        cmodel.removeExercise(index);
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
            return CEWExerciseCell(
              cewe: item,
              handle: handle,
              index: index,
              inDrag: inDrag,
            );
          },
        );
      },
    );
  }

  Widget _header(BuildContext context, DataModel dmodel, CEWModel cmodel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            comp.CloseButton(color: Theme.of(context).colorScheme.primary),
            const Spacer(),
            comp.ModelCreateButton(
              title: widget.isCreate ? "Create" : "Save",
              isValid: cmodel.isValid(),
              textColor: cmodel.isValid()
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              onTap: () async {
                if (cmodel.isValid()) {
                  if (widget.isCreate) {
                    var w = await cmodel.createWorkout(dmodel);
                    if (w == null) {
                      return;
                    }
                    widget.onAction(w);
                    Navigator.of(context).pop();
                  } else {
                    var w = await cmodel.updateWorkout(dmodel);
                    if (w == null) {
                      return;
                    }
                    widget.onAction(w);
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ),
        sui.TextField(
          fieldPadding: const EdgeInsets.symmetric(horizontal: 16),
          showBackground: false,
          charLimit: 50,
          value: cmodel.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          labelText: "Title",
          onChanged: (val) => cmodel.setTitle(val),
        ),
        sui.TextField(
          fieldPadding: const EdgeInsets.symmetric(horizontal: 16),
          showBackground: false,
          value: cmodel.description,
          charLimit: 150,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
          labelText: "Description",
          onChanged: (val) => cmodel.setDescription(val),
        ),
      ],
    );
  }
}

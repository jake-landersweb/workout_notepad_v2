import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
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

class _CEW extends StatelessWidget {
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
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var cmodel = Provider.of<CEWModel>(context);
    return Scaffold(
      body: sui.AppBar.sheet(
        title: isCreate ? "Create Workout" : "Edit Workout",
        horizontalSpacing: 0,
        scrollController: ModalScrollController.of(context),
        largeTitlePadding: const EdgeInsets.only(left: 16),
        crossAxisAlignment: CrossAxisAlignment.center,
        leading: const [comp.CancelButton()],
        trailing: [
          comp.ModelCreateButton(
            title: isCreate ? "Create" : "Save",
            isValid: cmodel.isValid(),
            onTap: () async {
              if (cmodel.isValid()) {
                if (isCreate) {
                  var w = await cmodel.createWorkout(dmodel);
                  if (w == null) {
                    return;
                  }
                  onAction(w);
                  Navigator.of(context).pop();
                } else {
                  var w = await cmodel.updateWorkout(dmodel);
                  if (w == null) {
                    return;
                  }
                  onAction(w);
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
        children: [
          Center(child: _icon(context, cmodel)),
          const SizedBox(height: 16),
          _title(context, cmodel),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: comp.ActionButton(
              onTap: () {
                comp.cupertinoSheet(
                  context: context,
                  builder: (context) => SelectExercise(
                    onSelect: (e) {
                      cmodel.addExercise(
                          WorkoutExercise.fromExercise(cmodel.workout, e));
                    },
                  ),
                );
              },
              title: "Add Exercise",
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: comp.LabeledWidget(
              label: "Exercises (Click to edit)",
              padding: const EdgeInsets.fromLTRB(32, 0, 16, 0),
              child: comp.ReorderableList<CEWExercise>(
                items: cmodel.exercises,
                areItemsTheSame: (p0, p1) => p0.id == p1.id,
                onReorderFinished: (item, from, to, newItems) {
                  cmodel.refreshExercises(newItems);
                },
                onChildTap: ((item, index) {
                  comp.cupertinoSheet(
                    context: context,
                    builder: (context) => CEWExerciseEdit(
                      workoutId: cmodel.workout.workoutId,
                      exercise: item,
                      onSave: (e) => cmodel.updateExercise(index, e),
                    ),
                  );
                }),
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
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                          ),
                        ]),
                      ),
                    ],
                  );
                },
                builder: (item, index) {
                  return _exerciseCell2(context, dmodel, cmodel, item, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(BuildContext context, CEWModel cmodel) {
    return sui.Button(
      onTap: () => showIconPicker(
          context: context,
          initialIcon: cmodel.icon,
          closeOnSelection: true,
          onSelection: (icon) => cmodel.setIcon(icon)),
      child: Column(
        children: [
          getImageIcon(cmodel.icon, size: 100),
          Text(
            "Edit",
            style: TextStyle(
                fontSize: 12,
                color: sui.CustomColors.textColor(context).withOpacity(0.3),
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Widget _title(BuildContext context, CEWModel cmodel) {
    return sui.ListView<Widget>(
      childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      leadingPadding: 16,
      trailingPadding: 16,
      children: [
        sui.TextField(
          labelText: "Title",
          hintText: "Title (ex. Arm Day)",
          charLimit: 40,
          value: cmodel.title,
          showCharacters: true,
          onChanged: (val) => cmodel.setTitle(val),
        ),
        sui.TextField(
          labelText: "Description",
          charLimit: 100,
          maxLines: 4,
          value: cmodel.description,
          showCharacters: true,
          onChanged: (val) => cmodel.setDescription(val),
        ),
      ],
    );
  }

  Widget _exerciseCell2(
    BuildContext context,
    DataModel dmodel,
    CEWModel cmodel,
    CEWExercise item,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Text(
            item.exercise.title,
            style: ttLabel(context, color: dmodel.color),
          ),
          // sets and reps
          Text(
            "${item.exercise.sets} x ${item.exercise.reps}",
            style: ttBody(context),
          ),
          // super sets
          for (var i in item.children)
            RichText(
              text: TextSpan(
                text: "- ",
                style: ttBody(context),
                children: [
                  TextSpan(
                    text: i.title,
                    style: ttBody(
                      context,
                      color: dmodel.color,
                    ),
                  ),
                  TextSpan(
                    text: " (${i.sets} x ${i.reps})",
                    style: ttBody(
                      context,
                      color:
                          sui.CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

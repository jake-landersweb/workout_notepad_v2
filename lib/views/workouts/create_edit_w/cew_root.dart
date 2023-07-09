import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/field.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
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
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) => _body(context),
        );
      },
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var cmodel = Provider.of<CEWModel>(context);
    return comp.InteractiveSheet(
      header: ((context) => _header(context, dmodel, cmodel)),
      builder: (context) {
        return Stack(
          children: [
            comp.RawReorderableList<CEWExercise>(
              items: cmodel.exercises,
              areItemsTheSame: (p0, p1) => p0.id == p1.id,
              footer:
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
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
                return CEWExerciseCell(
                  cewe: item,
                  handle: handle,
                  index: index,
                  inDrag: inDrag,
                );
              },
            ),
            // floating action here bc scaffold effects
            // touch area
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: AppColors.cell(context)[500],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 0.5),
                    Row(
                      children: [
                        _bottomItem(context, "Select Exercises", () {
                          comp.cupertinoSheet(
                            context: context,
                            builder: (context) => SelectExercise(
                              selectedIds: cmodel.exercises
                                  .map((e) => e.exercise.exerciseId)
                                  .toList(),
                              onDeselect: (e) {
                                cmodel.exercises.removeWhere(
                                  (element) =>
                                      element.exercise.exerciseId ==
                                      e.exerciseId,
                                );
                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                cmodel.notifyListeners();
                              },
                              onSelect: (e) {
                                cmodel.addExercise(WorkoutExercise.fromExercise(
                                    cmodel.workout, e));
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
            comp.CloseButton(color: AppColors.subtext(context), useRoot: true),
            const Spacer(),
            Clickable(
              onTap: () async {
                if (cmodel.isValid()) {
                  if (widget.isCreate) {
                    var w = await cmodel.createWorkout(dmodel);
                    if (w == null) {
                      return;
                    }
                    widget.onAction(w);
                    Navigator.of(context, rootNavigator: true).pop();
                  } else {
                    var w = await cmodel.updateWorkout(dmodel);
                    if (w == null) {
                      return;
                    }
                    widget.onAction(w);
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                }
              },
              child: Text(
                widget.isCreate ? "Create" : "Save",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: cmodel.isValid()
                      ? AppColors.text(context)
                      : Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
        Field(
          fieldPadding: const EdgeInsets.symmetric(horizontal: 16),
          showBackground: false,
          charLimit: 50,
          value: cmodel.title,
          highlightColor: Theme.of(context).colorScheme.onPrimary,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.text(context),
          ),
          labelText: "Title",
          onChanged: (val) => cmodel.setTitle(val),
        ),
        Field(
          fieldPadding: const EdgeInsets.symmetric(horizontal: 16),
          showBackground: false,
          value: cmodel.description,
          highlightColor: Theme.of(context).colorScheme.onPrimary,
          charLimit: 150,
          style: TextStyle(color: AppColors.subtext(context)),
          labelText: "Description",
          onChanged: (val) => cmodel.setDescription(val),
        ),
      ],
    );
  }

  Widget _bottomItem(BuildContext context, String title, VoidCallback onTap) {
    return Expanded(
      child: Clickable(
        onTap: onTap,
        child: Container(
          color: AppColors.cell(context)[400],
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

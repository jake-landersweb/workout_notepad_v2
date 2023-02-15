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
  double _offsetY = -5;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _offsetY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var cmodel = Provider.of<CEWModel>(context);
    return Container(
      color: sui.CustomColors.backgroundColor(context),
      height: double.infinity,
      child: Column(
        children: [
          _header(context, dmodel, cmodel),
          Expanded(
            child: comp.RawReorderableList<CEWExercise>(
              items: cmodel.exercises,
              footer: AnimatedOpacity(
                opacity: cmodel.showExerciseButton ? 1 : 0,
                curve: Sprung(36),
                duration: const Duration(milliseconds: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(height: 0.5),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                      child: comp.ActionButton(
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
                        title: "Add Exercise",
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
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
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
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, DataModel dmodel, CEWModel cmodel) {
    return AnimatedSlide(
      offset: Offset(0, _offsetY),
      duration: const Duration(milliseconds: 500),
      curve: Sprung(36),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              dmodel.color.shade300,
              dmodel.color.shade800,
            ],
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    comp.CloseButton(color: Colors.white.withOpacity(0.5)),
                    const Spacer(),
                    comp.ModelCreateButton(
                      title: widget.isCreate ? "Create" : "Save",
                      isValid: cmodel.isValid(),
                      textColor: cmodel.isValid()
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  labelText: "Title",
                  onChanged: (val) => cmodel.setTitle(val),
                ),
                sui.TextField(
                  fieldPadding: const EdgeInsets.symmetric(horizontal: 16),
                  showBackground: false,
                  value: cmodel.description,
                  charLimit: 150,
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  labelText: "Description",
                  onChanged: (val) => cmodel.setDescription(val),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget build2(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var cmodel = Provider.of<CEWModel>(context);
    return Scaffold(
      body: sui.AppBar.sheet(
        title: widget.isCreate ? "Create Workout" : "Edit Workout",
        horizontalSpacing: 0,
        scrollController: ModalScrollController.of(context),
        largeTitlePadding: const EdgeInsets.only(left: 16),
        crossAxisAlignment: CrossAxisAlignment.center,
        leading: const [comp.CancelButton()],
        trailing: [
          comp.ModelCreateButton(
            title: widget.isCreate ? "Create" : "Save",
            isValid: cmodel.isValid(),
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
          item.exercise.info(context),
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
                    text: " (",
                    style: ttBody(
                      context,
                      color:
                          sui.CustomColors.textColor(context).withOpacity(0.5),
                    ),
                    children: [
                      i.infoRaw(
                        context,
                        style: ttBody(
                          context,
                          color: sui.CustomColors.textColor(context)
                              .withOpacity(0.5),
                        ),
                      ),
                      TextSpan(
                        text: ")",
                        style: ttBody(
                          context,
                          color: sui.CustomColors.textColor(context)
                              .withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

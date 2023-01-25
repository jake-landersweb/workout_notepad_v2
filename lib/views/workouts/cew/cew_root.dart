import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';
import 'package:workout_notepad_v2/views/root.dart';

class CEWRoot extends StatefulWidget {
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
  State<CEWRoot> createState() => _CEWRootState();
}

class _CEWRootState extends State<CEWRoot> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider(
      create: (context) => widget.isCreate
          ? CEWModel.create(dmodel)
          : CEWModel.update(widget.workout!),
      builder: (context, _) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var cmodel = Provider.of<CEWModel>(context);
    return Scaffold(
      body: sui.AppBar(
        title: "Create Workout",
        horizontalSpacing: 0,
        isLarge: true,
        largeTitlePadding: const EdgeInsets.only(left: 16),
        crossAxisAlignment: CrossAxisAlignment.center,
        leading: const [comp.BackButton()],
        trailing: [
          sui.Button(
            onTap: () async {
              if (cmodel.isValid()) {
                if (widget.isCreate) {
                  var w = await cmodel.createWorkout(dmodel);
                  if (w == null) {
                    return;
                  }
                  widget.onAction(w);
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text(
              widget.isCreate ? "Create" : "Update",
              style: ttLabel(context, color: dmodel.color),
            ),
          )
        ],
        children: [
          Center(child: _icon(context, cmodel)),
          const SizedBox(height: 16),
          _title(context, cmodel),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: comp.ActionButton(
              onTap: () {
                sui.showFloatingSheet(
                  context: context,
                  childSpace: 0,
                  builder: (context) => SelectExercise(
                    useCupertino: true,
                    useRoot: true,
                    onSelect: (e) => cmodel.addExercise(e),
                  ),
                );
              },
              title: "Add Exercise",
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: comp.LabeledWidget(
              label: "Exercises",
              padding: const EdgeInsets.fromLTRB(32, 0, 16, 0),
              child: comp.ReorderableList<CEWExercise>(
                items: cmodel.exercises,
                areItemsTheSame: (p0, p1) => p0.id == p1.id,
                onReorderFinished: (item, from, to, newItems) {
                  setState(() {
                    cmodel.exercises
                      ..clear()
                      ..addAll(newItems);
                  });
                },
                onChildTap: ((item, index) {
                  sui.showCupertinoSheet(
                    context: context,
                    builder: (context) => CEWExerciseEdit(
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
          onSelection: (icon) {
            setState(() {
              cmodel.icon = icon;
            });
          }),
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
          onChanged: (val) {
            setState(() {
              cmodel.title = val;
            });
          },
        ),
        sui.TextField(
          labelText: "Description",
          charLimit: 100,
          value: cmodel.description,
          showCharacters: true,
          onChanged: (val) {
            setState(() {
              cmodel.description = val;
            });
          },
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

  Widget _exerciseCell(BuildContext context, DataModel dmodel, CEWModel cmodel,
      CEWExercise item, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            item.exercise.title,
            style: ttSubTitle(context, color: dmodel.color),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    comp.NumberPicker(
                      showPicker: false,
                      textFontSize: 40,
                      intialValue: item.exercise.sets,
                      onChanged: (val) {
                        setState(() {
                          item.exercise.sets = val;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "SETS",
                        style: TextStyle(
                          fontSize: 12,
                          color: dmodel.color.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("x", style: ttLabel(context, color: dmodel.color)),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    comp.NumberPicker(
                      showPicker: false,
                      textFontSize: 40,
                      intialValue: item.exercise.reps,
                      onChanged: (val) {
                        setState(() {
                          item.exercise.reps = val;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "REPS",
                        style: TextStyle(
                          fontSize: 12,
                          color: dmodel.color.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (item.children.isNotEmpty)
          // exercise children
          comp.LabeledWidget(
            label: "SUPER SETS",
            child: comp.ReorderableList<Exercise>(
              items: item.children,
              areItemsTheSame: (p0, p1) => p0.exerciseId == p1.exerciseId,
              onReorderFinished: (it, from, to, newItems) {
                setState(() {
                  cmodel.exercises[index].children
                    ..clear()
                    ..addAll(newItems);
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
              builder: (ex, exindex) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.title,
                        style: ttSubTitle(context, color: dmodel.color),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                comp.NumberPicker(
                                  showPicker: false,
                                  textFontSize: 40,
                                  intialValue: ex.sets,
                                  onChanged: (val) {
                                    setState(() {
                                      cmodel.exercises[index].children[exindex]
                                          .sets = val;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    "SETS",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: dmodel.color.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("x",
                                style: ttLabel(context, color: dmodel.color)),
                          ),
                          Expanded(
                            child: Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                comp.NumberPicker(
                                  showPicker: false,
                                  textFontSize: 40,
                                  intialValue: ex.reps,
                                  onChanged: (val) {
                                    setState(() {
                                      cmodel.exercises[index].children[exindex]
                                          .reps = val;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    "REPS",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: dmodel.color.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: comp.ActionButton(
            onTap: () {
              sui.showFloatingSheet(
                context: context,
                builder: (context) => SelectExercise(onSelect: (e) {
                  cmodel.addExerciseChild(index, e);
                }),
              );
            },
            title: "Add Super-Set",
            minHeight: 30,
          ),
        ),
      ],
    );
  }
}

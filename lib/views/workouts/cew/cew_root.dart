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
    this.workout,
    this.onCreate,
    this.onUpdate,
    this.useRoot = true,
  });
  final bool isCreate;
  final Workout? workout;
  final VoidCallback? onCreate;
  final VoidCallback? onUpdate;
  final bool useRoot;

  @override
  State<CEWRoot> createState() => _CEWRootState();
}

class _CEWRootState extends State<CEWRoot> with TickerProviderStateMixin {
  @override
  void initState() {
    if (widget.isCreate && widget.onCreate == null) {
      throw "If [isCreate] is true, [onCreate] cannot be null";
    }
    if (!widget.isCreate &&
        (widget.onUpdate == null || widget.workout == null)) {
      throw "If [isCreate] is false, [onUpdate, workout] cannot be null";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => widget.isCreate
          ? CEWModel.create()
          : CEWModel.update(widget.workout!),
      builder: (context, _) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var cmodel = Provider.of<CEWModel>(context);
    return sui.AppBar.sheet(
      title: "Create Workout",
      horizontalSpacing: 0,
      crossAxisAlignment: CrossAxisAlignment.center,
      leading: [comp.CloseButton(useRoot: widget.useRoot)],
      children: [
        Center(child: _icon(context, cmodel)),
        const SizedBox(height: 16),
        _title(context, cmodel),
        const SizedBox(height: 16),
        comp.LabeledWidget(
          label: "Exercises",
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
              return _exerciseCell(context, dmodel, cmodel, item, index);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: comp.ActionButton(
            onTap: () {
              sui.showFloatingSheet(
                context: context,
                childSpace: 0,
                builder: (context) => sui.FloatingSheet(
                  title: "Select or Create",
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SelectExercise(
                    header: const SizedBox(height: 16),
                    footer: const SizedBox(height: 16),
                    onSelect: (e) => cmodel.addExercise(e),
                  ),
                ),
              );
            },
            title: "Add Exercise",
          ),
        ),
      ],
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

  Widget _exerciseCell(BuildContext context, DataModel dmodel, CEWModel cmodel,
      CEWExercise item, int index) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 32,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.exercise.title,
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
                  child:
                      Text("x", style: ttLabel(context, color: dmodel.color)),
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
            const SizedBox(height: 8),
            comp.ActionButton(
              title: "Add Super-Set",
              minHeight: 30,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

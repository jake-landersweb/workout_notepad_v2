import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/contained_list.dart';
import 'package:workout_notepad_v2/components/field.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/components/segmented_picker.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/exercises/create_edit_exercise/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';

class CEERoot extends StatefulWidget {
  const CEERoot({
    super.key,
    required this.isCreate,
    this.onAction,
    this.exercise,
    this.runPostAction = true,
  });
  final bool isCreate;
  final Exercise? exercise;
  final Function(Exercise e)? onAction;
  final bool runPostAction;

  @override
  State<CEERoot> createState() => _CEERootState();
}

class _CEERootState extends State<CEERoot> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider(
      create: (context) => widget.isCreate
          ? CreateExerciseModel.create(dmodel, dmodel.user!.userId)
          : CreateExerciseModel.update(dmodel, widget.exercise!),
      builder: (context, child) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var cemodel = Provider.of<CreateExerciseModel>(context);
    return HeaderBar.sheet(
      title: widget.isCreate ? "Create Exercise" : "Update Exercise",
      isFluid: true,
      itemSpacing: 16,
      crossAxisAlignment: CrossAxisAlignment.center,
      leading: const [comp.CancelButton()],
      trailing: [
        comp.ModelCreateButton(
          title: widget.isCreate ? "Create" : "Save",
          isValid: cemodel.isValid(),
          onTap: () async {
            if (widget.runPostAction) {
              Exercise? response = await cemodel.post(dmodel, !widget.isCreate);
              if (response != null) {
                if (widget.runPostAction) {
                  await dmodel.refreshExercises();
                  await dmodel.refreshCategories();
                }
                if (widget.onAction != null) {
                  widget.onAction!(cemodel.exercise);
                }
              }
              Navigator.of(context).pop();
            } else {
              widget.onAction!(cemodel.exercise);
            }
          },
        )
      ],
      horizontalSpacing: 0,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _title(context, cemodel),
        ),
        comp.Section(
          "Category",
          initOpen: true,
          allowsCollapse: true,
          headerPadding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: _category(context, cemodel, dmodel),
        ),
        if (widget.isCreate)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedPicker(
              titles: const ["Weighted", "Timed", "Duration"],
              selections: const [
                ExerciseType.weight,
                ExerciseType.timed,
                ExerciseType.duration
              ],
              style: SegmentedPickerStyle(
                height: 36,
                pickerColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.5),
                selectedTextColor: Theme.of(context).colorScheme.onPrimary,
                selectedWeight: FontWeight.w500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onSelection: (p0) {
                setState(() {
                  cemodel.exercise.type = p0;
                });
              },
              selection: cemodel.exercise.type,
            ),
          ),
        for (var i in _setBody(context, cemodel)) i
      ],
    );
  }

  Widget _icon(BuildContext context, CreateExerciseModel cemodel) {
    return Clickable(
      onTap: () => showIconPicker(
          context: context,
          initialIcon: cemodel.exercise.icon,
          closeOnSelection: true,
          onSelection: (icon) {
            setState(() {
              cemodel.exercise.icon = icon;
            });
          }),
      child: Column(
        children: [
          getImageIcon(cemodel.exercise.icon, size: 100),
          Text(
            "Edit",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(BuildContext context, CreateExerciseModel cemodel) {
    return ContainedList<Widget>(
      childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      leadingPadding: 0,
      trailingPadding: 0,
      children: [
        Field(
          labelText: "Title",
          hintText: "Title (ex. Bicep Curls)",
          charLimit: 40,
          value: cemodel.exercise.title,
          showCharacters: true,
          onChanged: (val) {
            setState(() {
              cemodel.exercise.title = val;
            });
          },
        ),
        Field(
          labelText: "Note",
          charLimit: 100,
          maxLines: 3,
          value: cemodel.exercise.description,
          showCharacters: true,
          onChanged: (val) {
            setState(() {
              cemodel.exercise.description = val;
            });
          },
        ),
      ],
    );
  }

  Widget _category(
      BuildContext context, CreateExerciseModel cemodel, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Clickable(
            onTap: () {
              comp.cupertinoSheet(
                context: context,
                builder: (context) => CreateCategory(
                    categories: dmodel.categories.map((e) => e.title).toList(),
                    onCompletion: (val, icon) async {
                      var c = Category(
                        userId: dmodel.user!.userId,
                        title: val,
                        icon: icon,
                      );
                      await c.insert(
                        conflictAlgorithm: ConflictAlgorithm.replace,
                      );
                      await dmodel.refreshCategories();
                      setState(() {
                        cemodel.exercise.category = c.title;
                      });
                    }),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
              ),
              height: 40,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Icon(
                  LineIcons.plus,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ),
          for (int i = 0; i < dmodel.categories.length; i++)
            _categoryCell(context, dmodel.categories[i], cemodel),
        ],
      ),
    );
  }

  Widget _categoryCell(
      BuildContext context, Category category, CreateExerciseModel cemodel) {
    return Clickable(
      onTap: () {
        setState(() {
          cemodel.exercise.category = category.title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: category.title == cemodel.exercise.category
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
        ),
        height: 40,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category.icon != "")
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: getImageIcon(category.icon, size: 25),
                ),
              Text(
                category.title.capitalize(),
                style: TextStyle(
                  color: category.title == cemodel.exercise.category
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _setBody(BuildContext context, CreateExerciseModel cemodel) {
    switch (cemodel.exercise.type) {
      case ExerciseType.timed:
      case ExerciseType.duration:
        return [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _sets(context, cemodel),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _time(context, cemodel),
          ),
        ];
      default:
        return [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _sets(context, cemodel),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _reps(context, cemodel),
          ),
        ];
    }
  }

  Widget _sets(BuildContext context, CreateExerciseModel cemodel) {
    return comp.LabeledWidget(
      label: "Sets",
      child: comp.NumberPicker(
        minValue: 0,
        intialValue: cemodel.exercise.sets,
        onChanged: (val) {
          cemodel.exercise.sets = val;
        },
      ),
    );
  }

  Widget _reps(BuildContext context, CreateExerciseModel cemodel) {
    return comp.LabeledWidget(
      label: "Rep Goal",
      child: comp.NumberPicker(
        minValue: 0,
        intialValue: cemodel.exercise.reps,
        onChanged: (val) {
          cemodel.exercise.reps = val;
        },
      ),
    );
  }

  Widget _time(BuildContext context, CreateExerciseModel cemodel) {
    return comp.LabeledWidget(
      label: cemodel.exercise.type == ExerciseType.timed ? "Time" : "Goal Time",
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: comp.NumberPicker(
                        minValue: 0,
                        intialValue: cemodel.exercise.getHours(),
                        showPicker: false,
                        textFontSize: 50,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        maxValue: 99,
                        onChanged: (val) {
                          cemodel.exercise.setHours(val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text("Hours"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              ":",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 60,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: comp.NumberPicker(
                        minValue: 0,
                        intialValue: cemodel.exercise.getMinutes(),
                        showPicker: false,
                        textFontSize: 50,
                        maxValue: 59,
                        onChanged: (val) {
                          cemodel.exercise.setMinutes(val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text("Minutes"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              ":",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 60,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: comp.NumberPicker(
                        minValue: 0,
                        intialValue: cemodel.exercise.getSeconds(),
                        showPicker: false,
                        textFontSize: 50,
                        maxValue: 59,
                        onChanged: (val) {
                          cemodel.exercise.setSeconds(val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text("Seconds"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

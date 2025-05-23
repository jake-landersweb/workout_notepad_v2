import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/contained_list.dart';
import 'package:workout_notepad_v2/components/field.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/components/section.dart';
import 'package:workout_notepad_v2/components/segmented_picker.dart';
import 'package:workout_notepad_v2/components/time_picker.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/image.dart';
import 'package:workout_notepad_v2/views/exercises/create_edit_exercise/cee_type.dart';
import 'package:workout_notepad_v2/views/exercises/create_edit_exercise/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/profile/paywall.dart';

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
  bool _isLoading = false;
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
      crossAxisAlignment: CrossAxisAlignment.center,
      leading: const [comp.CancelButton()],
      trailing: [
        comp.ModelCreateButton(
          title: widget.isCreate ? "Create" : "Save",
          isValid: cemodel.isValid(),
          isLoading: _isLoading,
          onTap: () async {
            if (widget.runPostAction) {
              setState(() {
                _isLoading = true;
              });
              Exercise? response =
                  await cemodel.post(context, dmodel, !widget.isCreate);
              if (response != null) {
                if (widget.runPostAction) {
                  await dmodel.refreshExercises();
                  await dmodel.refreshCategories();
                }
                if (widget.onAction != null) {
                  widget.onAction!(cemodel.exercise);
                }
                Navigator.of(context).pop();
              } else {
                setState(() {
                  _isLoading = false;
                });
              }
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
          child: Section(
            "Asset",
            initOpen: false,
            allowsCollapse: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: _getAssetWidget(context, cemodel),
                    ),
                  ),
                  if (cemodel.file.file != null)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Clickable(
                        onTap: () {
                          setState(() {
                            cemodel.file.deleteFile();
                          });
                          cemodel.deleteFile = true;
                          cemodel.fileChanged = true;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cell(context),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppColors.subtext(context),
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _title(context, cemodel),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Clickable(
            onTap: () {
              comp.cupertinoSheet(
                context: context,
                builder: (cntext) => CEEType(
                  type: cemodel.exercise.type,
                  isCreate: widget.isCreate,
                  onSelect: (type) {
                    setState(() {
                      cemodel.exercise.type = type;
                    });
                  },
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cell(context),
                borderRadius: BorderRadius.circular(10),
              ),
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Image.asset(exerciseTypeIcon(cemodel.exercise.type),
                        height: 40, width: 40),
                    const SizedBox(width: 8),
                    Expanded(
                      child: comp.LabeledCell(
                        label: "Type",
                        child: Text(
                          exerciseTypeTitle(cemodel.exercise.type),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedPicker(
            style: SegmentedPickerStyle(
              height: 40,
              backgroundColor: AppColors.cell(context),
              pickerColor: _pickerColor(context, cemodel).withOpacity(0.3),
              selectedTextColor: _pickerColor(context, cemodel),
            ),
            titles: const ["Beginner", "Intermediate", "Advanced"],
            selection: cemodel.exercise.difficulty,
            onSelection: (v) {
              setState(() {
                cemodel.exercise.difficulty = v;
              });
            },
          ),
        ),
        comp.Section(
          "Category",
          initOpen: true,
          allowsCollapse: true,
          headerPadding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: _category(context, cemodel, dmodel),
        ),
        for (var i in _setBody(context, cemodel))
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: i,
          ),
      ],
    );
  }

  // Widget _icon(BuildContext context, CreateExerciseModel cemodel) {
  //   return Clickable(
  //     onTap: () => showIconPicker(
  //         context: context,
  //         initialIcon: cemodel.exercise.icon,
  //         closeOnSelection: true,
  //         onSelection: (icon) {
  //           setState(() {
  //             cemodel.exercise.icon = icon;
  //           });
  //         }),
  //     child: Column(
  //       children: [
  //         getImageIcon(cemodel.exercise.icon, size: 100),
  //         Text(
  //           "Edit",
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Theme.of(context).colorScheme.secondary,
  //             fontWeight: FontWeight.w300,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _title(BuildContext context, CreateExerciseModel cemodel) {
    return ContainedList<Widget>(
      childPadding: EdgeInsets.zero,
      leadingPadding: 0,
      trailingPadding: 0,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Field(
            labelText: "Title",
            hintText: "Title (ex. Bicep Curls)",
            charLimit: 40,
            textCapitalization: TextCapitalization.words,
            value: cemodel.exercise.title,
            showCharacters: true,
            onChanged: (val) {
              setState(() {
                cemodel.exercise.title = val;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Field(
            value: cemodel.exercise.description,
            hintText:
                "Description (Break down the exercise into steps to make it easier to follow.)",
            labelText: "Description",
            onChanged: (v) {
              setState(() {
                cemodel.exercise.description = v;
              });
            },
            isLabeled: false,
            maxLines: 5,
            minLines: 5,
          ),
        ),
        // comp.WrappedButton(
        //   title: "Exercise Details",
        //   icon: Icons.info_outline_rounded,
        //   rowAxisSize: MainAxisSize.max,
        //   onTap: () => cupertinoSheet(
        //     context: context,
        //     builder: (context) => CEEDetails(cemodel: cemodel),
        //   ),
        // ),
      ],
    );
  }

  Widget _category(
    BuildContext context,
    CreateExerciseModel cemodel,
    DataModel dmodel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (dmodel.hasValidSubscription())
            Clickable(
              onTap: () {
                comp.cupertinoSheet(
                  context: context,
                  builder: (context) => CreateCategory(
                    categories: dmodel.categories.map((e) => e.title).toList(),
                    onCompletion: (val, icon) async {
                      var c = Category.init(
                        title: val,
                        icon: icon,
                      );
                      await c.insert(
                        conflictAlgorithm: ConflictAlgorithm.replace,
                      );
                      await dmodel.refreshCategories();
                      setState(() {
                        cemodel.exercise.category = c.categoryId;
                      });
                    },
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cell(context),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          cemodel.exercise.category = category.categoryId;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: category.categoryId == cemodel.exercise.category
              ? Theme.of(context).colorScheme.primary
              : AppColors.cell(context),
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
                  color: category.categoryId == cemodel.exercise.category
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
                        initialValueStr: cemodel.exercise.getHours() < 10
                            ? "0${cemodel.exercise.getHours()}"
                            : cemodel.exercise.getHours().toString(),
                        showPicker: false,
                        customFormatter:
                            TimeInputFormatter(maxValue: 99, minValue: 0),
                        textFontSize: 50,
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
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 20),
            child: Text(
              ":",
              style: TextStyle(
                fontSize: 60,
                color: AppColors.subtext(context),
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
                        initialValueStr: cemodel.exercise.getMinutes() < 10
                            ? "0${cemodel.exercise.getMinutes()}"
                            : cemodel.exercise.getMinutes().toString(),
                        showPicker: false,
                        customFormatter:
                            TimeInputFormatter(maxValue: 59, minValue: 0),
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
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 20),
            child: Text(
              ":",
              style: TextStyle(
                fontSize: 60,
                color: AppColors.subtext(context),
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
                        initialValueStr: cemodel.exercise.getSeconds() < 10
                            ? "0${cemodel.exercise.getSeconds()}"
                            : cemodel.exercise.getSeconds().toString(),
                        showPicker: false,
                        customFormatter:
                            TimeInputFormatter(maxValue: 59, minValue: 0),
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

  Widget _getAssetWidget(BuildContext context, CreateExerciseModel cemodel) {
    var dmodel = Provider.of<DataModel>(context);
    if (cemodel.file.file == null) {
      return Clickable(
        onTap: () async {
          if (!dmodel.hasValidSubscription()) {
            showPaywall(context);
          } else {
            await promptMedia(
              context: context,
              onSelected: (file) {
                if (file == null) {
                  print("There was an issue picking the file");
                }
                setState(() {
                  cemodel.file.setFile(file: file!);
                });
              },
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose an Asset",
                  style: ttLabel(context),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: cemodel.file.getRenderer(),
    );
  }

  Color _pickerColor(BuildContext context, CreateExerciseModel cemodel) {
    switch (cemodel.exercise.difficulty) {
      case "Intermediate":
        return Colors.amber[600]!;
      case "Advanced":
        return Colors.red[300]!;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

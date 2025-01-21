import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/select_exercise.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/cew_configure.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/root.dart';

class CEW extends StatefulWidget {
  const CEW({
    super.key,
    this.workout,
    this.onAction,
    this.updateDatabase = true,
  });
  final Workout? workout;
  final Function(Workout workout)? onAction;
  final bool updateDatabase;

  @override
  State<CEW> createState() => _CEWState();
}

class _CEWState extends State<CEW> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => widget.workout == null
          ? CEWModel.create()
          : CEWModel.update(widget.workout!),
      builder: (context, _) => _root(context),
    );
  }

  Widget _root(BuildContext context) {
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
    return Scaffold(
      body: InteractiveSheet(
        header: ((context) => _header(context, dmodel, cmodel)),
        headerColor: AppColors.background(context),
        builder: (context) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Consumer<CEWModel>(
                builder: (context, model, child) {
                  return CEWConfigure(
                    exercises: model.workout.getExercises(),
                    onReorderFinish: (exercises) {
                      setState(() {
                        model.workout.setExercises(exercises);
                      });
                    },
                    removeAt: (index) {
                      setState(() {
                        model.workout.removeExercise(index);
                      });
                    },
                    onGroupReorder: (int i, List<Exercise> group) {
                      setState(() {
                        model.workout.setSuperSets(i, group);
                      });
                    },
                    removeSuperset: (int i, int j) {
                      setState(() {
                        model.workout.removeSuperSet(i, j);
                      });
                    },
                    addExercise: (int index, Exercise e) {
                      setState(() {
                        model.workout.addExercise(index, e);
                      });
                    },
                    sState: () {
                      setState(() {});
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, DataModel dmodel, CEWModel cmodel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CloseButton2(color: AppColors.subtext(context), useRoot: true),
            const Spacer(),
            Clickable(
              onTap: () async {
                var valid = cmodel.isValid();
                if (valid.v2) {
                  if (widget.updateDatabase) {
                    var response = await cmodel.action();
                    if (response) {
                      await dmodel.fetchData();
                      if (widget.onAction != null) {
                        widget.onAction!(cmodel.workout);
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                    } else {
                      snackbarErr(context, "There was an unknown issue");
                    }
                  } else {
                    if (widget.onAction != null) {
                      widget.onAction!(cmodel.workout);
                    }
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                } else {
                  snackbarErr(context, valid.v1);
                }
              },
              child: Text(
                cmodel.type == CEWType.create ? "Create" : "Save",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text(context),
                ),
              ),
            ),
          ],
        ),
        Field(
          fieldPadding: const EdgeInsets.symmetric(horizontal: 16),
          showBackground: false,
          charLimit: 50,
          value: cmodel.workout.title,
          highlightColor: dmodel.color,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.text(context),
          ),
          textCapitalization: TextCapitalization.words,
          labelText: "Title",
          onChanged: (val) => cmodel.setTitle(val),
        ),
        Row(
          children: [
            Expanded(
              child: _headerButton(
                context,
                Icons.description_outlined,
                () {
                  showFloatingSheet(
                    context: context,
                    builder: (context) {
                      return FloatingSheet(
                        title: "Description",
                        closeText: "Done",
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cell(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Field(
                              fieldPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              showBackground: false,
                              maxLines: 3,
                              value: cmodel.workout.description,
                              highlightColor: dmodel.color,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.text(context),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              labelText: "",
                              onChanged: (val) => cmodel.setDescription(val),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // const SizedBox(width: 8),
            // Expanded(
            //   child: _headerButton(
            //     context,
            //     _isReordering ? Icons.check_circle_outline : Icons.reorder,
            //     () {
            //       setState(() {
            //         _isReordering = !_isReordering;
            //       });
            //     },
            //   ),
            // ),
            const SizedBox(width: 8),
            Expanded(
              child: _headerButton(
                context,
                Icons.add_circle_outline,
                () {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => SelectExercise(
                      onSelect: (e) {
                        cmodel.addExercise(
                          cmodel.workout.getExercises().length,
                          e,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  Widget _headerButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Clickable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cell(context),
          border: Border.all(color: AppColors.border(context), width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(4),
        child: Icon(
          icon,
          color: AppColors.text(context).withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

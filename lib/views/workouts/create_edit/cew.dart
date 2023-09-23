import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/select_exercise.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/cew_reorder.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/root.dart';

class CEW extends StatefulWidget {
  const CEW({
    super.key,
    this.workout,
    this.onAction,
  });
  final Workout? workout;
  final Function(Workout workout)? onAction;

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
        builder: (context) {
          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  for (int i = 0; i < cmodel.workout.exercises.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: CEWCell(i: i),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: AppColors.cell(context)[500],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _bottomItem(context, "Re-Order", () {
                            cupertinoSheet(
                              context: context,
                              enableDrag: false,
                              builder: (context) => const CEWReorder(),
                            );
                          }),
                          const SizedBox(width: 1),
                          _bottomItem(context, "Add Exercises", () {
                            cupertinoSheet(
                              context: context,
                              builder: (context) => SelectExercise(
                                onSelect: (e) {
                                  cmodel.addExercise(
                                    cmodel.workout.exercises.length,
                                    e,
                                  );
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
        Field(
          fieldPadding: const EdgeInsets.symmetric(horizontal: 16),
          showBackground: false,
          value: cmodel.workout.description,
          highlightColor: dmodel.color,
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
          color: AppColors.cell(context)[200],
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

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;

class LWExerciseCell extends StatelessWidget {
  const LWExerciseCell({
    super.key,
    required this.workout,
    required this.exercise,
    required this.children,
  });
  final Workout workout;
  final WorkoutExercise exercise;
  final List<ExerciseSet> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              if (exercise.note != "")
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: sui.CellWrapper(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            LineIcons.infoCircle,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Center(
                              child: Text(
                                exercise.note,
                                style: ttBody(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              _exerciseDetails(context, exercise),
              if (children.isNotEmpty)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              color: sui.CustomColors.textColor(context)
                                  .withOpacity(0.1),
                              height: 1,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "SUPERSET",
                              style: ttBody(
                                context,
                                color: sui.CustomColors.textColor(context)
                                    .withOpacity(0.25),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: sui.CustomColors.textColor(context)
                                  .withOpacity(0.1),
                              height: 1,
                              width: double.infinity,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (var i in children) _exerciseDetails(context, i),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exerciseDetails(BuildContext context, ExerciseBase e) {
    Widget wrap(Widget child) {
      return Column(
        children: [
          child,
          if (e.description != "")
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                e.description,
                style: ttBody(
                  context,
                  color: sui.CustomColors.textColor(context).withOpacity(0.5),
                ),
              ),
            ),
        ],
      );
    }

    switch (e.type) {
      case 1:
        return wrap(_type1(context, e));
      default:
        return wrap(_type0(context, e));
    }
  }

  Widget _type0(BuildContext context, ExerciseBase e) {
    return comp.LabeledWidget(
      label: e.title,
      child: Row(
        children: [
          _detailCell(context, "sets", e.sets.toString()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "x",
              style: ttLabel(
                context,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          _detailCell(context, "reps", e.reps.toString()),
        ],
      ),
    );
  }

  Widget _type1(BuildContext context, ExerciseBase e) {
    return comp.LabeledWidget(
      label: e.title,
      child: Row(
        children: [
          _detailCell(context, "sets", e.sets.toString()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "x",
              style: ttLabel(
                context,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          _detailCell(context, e.timePost, e.time.toString()),
        ],
      ),
    );
  }

  Widget _detailCell(BuildContext context, String name, String val) {
    return Expanded(
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            width: double.infinity,
            child: Text(
              val,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 60,
                color: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.lighten(0.15),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              name.toUpperCase(),
              style: ttBody(
                context,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

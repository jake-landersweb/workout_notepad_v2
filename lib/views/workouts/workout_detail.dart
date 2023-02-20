import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';
import 'package:workout_notepad_v2/views/workouts/we_cell.dart';

class WorkoutDetail extends StatefulWidget {
  const WorkoutDetail({
    super.key,
    required this.workout,
  });
  final WorkoutCategories workout;

  @override
  State<WorkoutDetail> createState() => _WorkoutDetailState();
}

class _WorkoutDetailState extends State<WorkoutDetail> {
  late Workout _workout;
  List<WorkoutExercise> _exercises = [];

  @override
  void initState() {
    _workout = widget.workout.workout.copy();
    _init();
    super.initState();
  }

  Future<void> _init() async {
    var tmp = await _workout.getChildren();
    setState(() {
      _exercises = [];
      _exercises = tmp;
    });
  }

  Future<void> _postUpdate(Workout w) async {
    setState(() {
      _workout = w;
      _exercises = [];
    });
    // wait for db to load
    await Future.delayed(const Duration(milliseconds: 100));
    var tmp = await w.getChildren();
    setState(() {
      _exercises = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: sui.AppBar(
        title: _workout.title,
        isLarge: true,
        isFluid: true,
        itemSpacing: 8,
        horizontalSpacing: 0,
        largeTitlePadding: const EdgeInsets.only(left: 16),
        leading: const [comp.BackButton()],
        trailing: [
          comp.EditButton(
            onTap: () {
              showMaterialModalBottomSheet(
                context: context,
                enableDrag: false,
                builder: (context) => CEWRoot(
                  isCreate: false,
                  workout: _workout,
                  onAction: (workout) async => _postUpdate(workout),
                ),
              );
            },
          )
        ],
        children: [
          if ((_workout.description ?? "") != "")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _workout.description!,
                style: ttLabel(
                  context,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          _actions(context),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: comp.LabeledWidget(
              label: "Exercises",
              child: Container(),
            ),
          ),
          for (var item in _exercises)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ExerciseCell(exercise: item),
            ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            _actionCell(
              context: context,
              icon: Icons.play_arrow_rounded,
              title: "Start",
              description: "Launch the workout",
              onTap: () {
                showMaterialModalBottomSheet(
                  context: context,
                  enableDrag: false,
                  builder: (context) =>
                      LaunchWorkout(workout: _workout, exercises: _exercises),
                );
              },
            ),
            const SizedBox(width: 16),
            _actionCell(
              context: context,
              icon: Icons.sticky_note_2_rounded,
              title: "Logs",
              description: "View workout logs",
              onTap: () {
                // TODO -- implement
              },
            ),
            const SizedBox(width: 16),
            _actionCell(
              context: context,
              icon: Icons.delete_rounded,
              title: "Delete",
              description: "Delete this workout",
              onTap: () {
                // TODO -- implement
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCell({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final bgColor = Theme.of(context).colorScheme.tertiaryContainer;
    final textColor = Theme.of(context).colorScheme.onTertiaryContainer;
    return sui.Button(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 2.5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: textColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: ttLabel(
                  context,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: ttBody(
                  context,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

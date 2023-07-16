import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class CloneWorkout extends StatefulWidget {
  const CloneWorkout({
    super.key,
    required this.workout,
  });
  final Workout workout;

  @override
  State<CloneWorkout> createState() => _CloneWorkoutState();
}

class _CloneWorkoutState extends State<CloneWorkout> {
  late String _title;
  bool _isLoading = false;

  @override
  void initState() {
    _title = "${widget.workout.title} - Copy";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return comp.HeaderBar.sheet(
      title: "Clone Workout",
      leading: const [comp.CloseButton2()],
      children: [
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: comp.Field(
              labelText: "Title",
              showBackground: true,
              value: _title,
              onChanged: (v) {
                setState(() {
                  _title = v;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        WrappedButton(
          title: "Clone",
          bg: Theme.of(context).colorScheme.primary,
          fg: Colors.white,
          center: true,
          isLoading: _isLoading,
          onTap: () async {
            setState(() {
              _isLoading = true;
            });
            var cloned = await widget.workout.clone(_title);
            // insert in transaction
            var db = await getDB();
            await db.transaction((txn) async {
              await txn.insert("workout", cloned.workout.toMap());
              for (var i in cloned.exercises) {
                await txn.insert("workout_exercise", i.v1.toMap());
                for (var j in i.v2) {
                  await txn.insert("exercise_set", j.toMap());
                }
              }
            });
            await dmodel.refreshWorkouts();
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

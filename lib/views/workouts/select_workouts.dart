import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class SelectWorkouts extends StatefulWidget {
  const SelectWorkouts({
    super.key,
    required this.selectedIds,
    required this.onSelect,
  });
  final List<String> selectedIds;
  final List<String> Function(WorkoutCategories wc) onSelect;

  @override
  State<SelectWorkouts> createState() => _SelectWorkoutsState();
}

class _SelectWorkoutsState extends State<SelectWorkouts> {
  late List<String> _selectedIds;

  @override
  void initState() {
    _selectedIds = widget.selectedIds;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = context.read<DataModel>();
    return HeaderBar.sheet(
      title: "Select Workouts",
      trailing: const [CancelButton(title: "Done")],
      children: [
        for (var i in dmodel.workouts)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIds = widget.onSelect(i);
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: WorkoutCellSmall(
                wc: i,
                bg: _selectedIds
                        .any((element) => element == i.workout.workoutId)
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : AppColors.cell(context),
              ),
            ),
          ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 50),
      ],
    );
  }
}

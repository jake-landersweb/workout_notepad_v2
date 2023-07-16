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
    this.selectedIds,
    required this.onSelect,
    this.closeOnSelect = true,
  });
  final List<String>? selectedIds;
  final Function(Workout workout) onSelect;
  final bool closeOnSelect;

  @override
  State<SelectWorkouts> createState() => _SelectWorkoutsState();
}

class _SelectWorkoutsState extends State<SelectWorkouts> {
  late List<String> _selectedIds;

  @override
  void initState() {
    if (!widget.closeOnSelect && widget.selectedIds == null) {
      throw "`closeOnSelect` cannot be false while `selectedIds` is null";
    }
    if (widget.closeOnSelect) {
      _selectedIds = [];
    } else {
      _selectedIds = widget.selectedIds!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "Select Workouts",
      trailing: const [CancelButton(title: "Done")],
      children: [
        const SizedBox(height: 16),
        WrappedButton(
          title: "Create New",
          type: WrappedButtonType.main,
          center: true,
        ),
        const SizedBox(height: 16),
        for (var i in dmodel.workouts) _cell(context, i),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 50),
      ],
    );
  }

  Widget _cell(BuildContext context, Workout workout) {
    bool selected = _selectedIds.any((element) => element == workout.workoutId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: WorkoutCellSmall(
        workout: workout,
        bg: AppColors.cell(context),
        endWidget: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: WrappedButton(
                  title: "Details",
                  center: true,
                  bg: AppColors.cell(context)[500],
                  onTap: () {
                    cupertinoSheet(
                      context: context,
                      builder: (context) =>
                          WorkoutDetail.small(workout: workout),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: WrappedButton(
                  title: selected ? "Selected" : "Select",
                  icon: selected ? Icons.check : null,
                  fg: selected || widget.closeOnSelect
                      ? Colors.white
                      : AppColors.text(context),
                  bg: selected || widget.closeOnSelect
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.cell(context)[500],
                  iconBg: Colors.transparent,
                  iconFg: Colors.white,
                  iconSpacing: 4,
                  center: true,
                  rowAxisSize: MainAxisSize.max,
                  onTap: () {
                    widget.onSelect(workout);
                    if (widget.closeOnSelect) {
                      Navigator.of(context).pop();
                    } else {
                      throw "unimplemented";
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/cancel_button.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/data/workout_snapshot.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/workouts/snapshots/ws_detail.dart';

class WorkoutSnapshots extends StatefulWidget {
  const WorkoutSnapshots({
    super.key,
    required this.workout,
  });
  final Workout workout;

  @override
  State<WorkoutSnapshots> createState() => _WorkoutSnapshotsState();
}

class _WorkoutSnapshotsState extends State<WorkoutSnapshots> {
  bool _isLoading = true;
  List<WorkoutSnapshot> _snapshots = [];

  @override
  void initState() {
    _getSnapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) => HeaderBar.sheet(
            title: "Snapshots",
            trailing: const [
              CancelButton(
                title: "Done",
                useRoot: true,
              )
            ],
            children: [
              const SizedBox(height: 16),
              ContainedList<WorkoutSnapshot>(
                children: _snapshots,
                leadingPadding: 0,
                trailingPadding: 0,
                childPadding: const EdgeInsets.fromLTRB(16, 8, 8, 10),
                onChildTap: (context, item, index) => navigate(
                  context: context,
                  builder: (context) => WorkoutSnapshotDetail(snapshot: item),
                ),
                childBuilder: (context, item, index) =>
                    _snapshotCell(context, item),
              ),
              const SizedBox(height: 16),
              WrappedButton(
                title: "Create New Snapshot",
                rowAxisSize: MainAxisSize.max,
                center: true,
                isLoading: _isLoading,
                onTap: () async {
                  showAlert(
                    context: context,
                    title: "Confirm",
                    body: const Text(
                        "Are you sure you want to create a snapshot of the workout at this time?"),
                    cancelText: "Cancel",
                    onCancel: () {},
                    submitText: "Confirm",
                    submitBolded: true,
                    onSubmit: () async {
                      var db = await DatabaseProvider().database;
                      var snp = await widget.workout.toSnapshot(db);
                      await db.insert("workout_snapshot", snp.toMap());
                      await _getSnapshots();
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _snapshotCell(BuildContext context, WorkoutSnapshot snapshot) {
    final d = DateTime.fromMillisecondsSinceEpoch(snapshot.createdEpoch);
    return SizedBox(
      height: 45,
      child: Row(
        children: [
          Text(
            DateFormat('yyyy, MMMM d').format(d),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("-"),
          ),
          Text(
            DateFormat('h:mm:ss a').format(d),
            style: ttcaption(context),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.subtext(context),
          ),
        ],
      ),
    );
  }

  Future<void> _getSnapshots() async {
    setState(() {
      _isLoading = true;
    });
    // TODO -- dev for creating a snapshot
    // var snp = await widget.workout.toSnapshot();
    // var db = await DatabaseProvider().database;
    // await db.delete("workout_snapshot");
    // var response = await db.insert("workout_snapshot", snp.toMap());
    // print(response);

    _snapshots = await widget.workout.getSnapshots();
    setState(() {
      _isLoading = false;
    });
  }
}

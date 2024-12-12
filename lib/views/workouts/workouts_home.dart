import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/back_button.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/section.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/views/workouts/create_edit/root.dart';

class WorkoutsHome extends StatefulWidget {
  const WorkoutsHome({
    super.key,
    this.showBackButton = true,
  });
  final bool showBackButton;

  @override
  State<WorkoutsHome> createState() => _WorkoutsHomeState();
}

class _WorkoutsHomeState extends State<WorkoutsHome> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Scaffold(
      body: HeaderBar(
        title: "Templates",
        isLarge: true,
        bottomSpacing: 0,
        leading: const [BackButton2()],
        trailing: [
          comp.AddButton(
            onTap: () {
              showMaterialModalBottomSheet(
                context: context,
                enableDrag: false,
                builder: (context) => const CEW(),
              );
            },
          )
        ],
        children: [
          if (dmodel.workouts.isNotEmpty)
            Section("My Templates",
                allowsCollapse: true,
                initOpen: true,
                child: Column(
                  children: [
                    for (var i in dmodel.workouts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: WorkoutCell(workout: i),
                      ),
                  ],
                )),
          if (dmodel.defaultWorkouts.isNotEmpty)
            Section(
              "Default Templates",
              allowsCollapse: true,
              initOpen: false,
              child: Column(
                children: [
                  for (var i in dmodel.defaultWorkouts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: WorkoutCell(workout: i),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/snapshot.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';

class ManageData extends StatefulWidget {
  const ManageData({super.key});

  @override
  State<ManageData> createState() => _ManageDataState();
}

class _ManageDataState extends State<ManageData> {
  int _loadingIndex = -1;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);

    return Scaffold(
      body: HeaderBar(
        title: "Manage Data",
        isLarge: true,
        leading: const [BackButton2()],
        children: [
          Section(
            "Current Data",
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cell(context),
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Workouts - ${dmodel.currentMetadata.firstWhere((element) => element.table == 'workout').length}",
                    ),
                    Text(
                      "Workout Logs - ${dmodel.currentMetadata.firstWhere((element) => element.table == 'workout_log').length}",
                    ),
                    Text(
                      "Exercises - ${dmodel.currentMetadata.firstWhere((element) => element.table == 'exercise').length}",
                    ),
                    Text(
                      "Exercise Logs - ${dmodel.currentMetadata.firstWhere((element) => element.table == 'exercise_log').length}",
                    ),
                  ],
                ),
              ),
            ),
          ),
          Section(
            "Data Snapshots",
            child: Column(
              children: [
                ContainedList<Tuple2<Snapshot, DateTime>>(
                  leadingPadding: 0,
                  trailingPadding: 0,
                  childPadding: EdgeInsets.zero,
                  children: [
                    for (var i in dmodel.snapshots)
                      Tuple2(
                        i,
                        DateTime.fromMillisecondsSinceEpoch(i.created.round()),
                      ),
                  ],
                  onChildTap: (context, item, index) async {
                    setState(() {
                      _loadingIndex = 50 + index;
                    });
                    await showAlert(
                      context: context,
                      title: "Import Snapshot",
                      body: const Text(
                          "Importing this snapshot will overwrite all data that you currently have in app, and replace it with the contents of this snapshot. Are you sure?"),
                      cancelText: "Cancel",
                      onCancel: () {
                        setState(() {
                          _loadingIndex = -1;
                        });
                      },
                      cancelBolded: true,
                      submitText: "I'm Sure",
                      submitColor: Colors.red,
                      onSubmit: () async {
                        var response = await dmodel.importSnapshot(item.v1);
                        if (!response) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "There was an issue loading this snapshot"),
                              backgroundColor: Colors.red[300],
                            ),
                          );
                          setState(() {
                            _loadingIndex = -1;
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    );
                  },
                  childBuilder: (context, item, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                DateFormat('yyyy, MMMM d').format(item.v2),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text("-"),
                              ),
                              Text(
                                DateFormat('h:mm:ss a').format(item.v2),
                                style: ttcaption(context),
                              ),
                              const Spacer(),
                              if (_loadingIndex == 50 + index)
                                LoadingIndicator(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              if (index == 0 && _loadingIndex != 50 + index)
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                    child: Text(
                                      "Latest",
                                      style: ttcaption(
                                        context,
                                        color: AppColors.cell(context),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(),
                          ),
                          Text("Workouts - ${item.v1.workoutLength}"),
                          Text("Workout Logs - ${item.v1.workoutLogLength}"),
                          Text("Exercises - ${item.v1.exerciseLength}"),
                          Text("Exercise Logs - ${item.v1.exerciseLogLength}"),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                WrappedButton(
                  title: "Create Manual Snapshot",
                  rowAxisSize: MainAxisSize.max,
                  center: true,
                  isLoading: _loadingIndex == 99,
                  onTap: () async {
                    setState(() {
                      _loadingIndex = 99;
                    });
                    var response = await dmodel.snapshotData();
                    if (response) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Successfully created snapshot!"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "There was an issue uploading your data to the cloud"),
                          backgroundColor: Colors.red[300],
                        ),
                      );
                    }
                    setState(() {
                      _loadingIndex = -1;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
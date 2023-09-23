import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/snapshot.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

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
        title: "Manage Syncs",
        isLarge: true,
        leading: const [BackButton2()],
        children: [
          const Text(
            "Note: Snapshots will be created for you automatically every 8 hours on app launch.",
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
                  // onChildTap: (context, item, index) async {
                  //   setState(() {
                  //     _loadingIndex = 50 + index;
                  //   });
                  //   await showAlert(
                  //     context: context,
                  //     title: "Import Snapshot",
                  //     body: const Text(
                  //         "Importing this snapshot will overwrite all data that you currently have in app, and replace it with the contents of this snapshot. Are you sure?"),
                  //     cancelText: "Cancel",
                  //     onCancel: () {
                  //       setState(() {
                  //         _loadingIndex = -1;
                  //       });
                  //     },
                  //     cancelBolded: true,
                  //     submitText: "I'm Sure",
                  //     submitColor: Colors.red,
                  //     onSubmit: () async {
                  //       var response = await dmodel.importSnapshot(item.v1);
                  //       if (!response) {
                  //         snackbarErr(context,
                  //             "There was an issue loading this snapshot.");
                  //         setState(() {
                  //           _loadingIndex = -1;
                  //         });
                  //       } else {
                  //         Navigator.of(context).pop();
                  //       }
                  //     },
                  //   );
                  // },
                  childBuilder: (context, item, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 13, 13, 8),
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
                              // const Spacer(),
                              // Icon(
                              //   Icons.chevron_right_rounded,
                              //   color: AppColors.subtext(context),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                WrappedButton(
                  title: "Create Manual Snapshot",
                  rowAxisSize: MainAxisSize.max,
                  type: WrappedButtonType.main,
                  center: true,
                  isLoading: _loadingIndex == 99,
                  onTap: () async {
                    setState(() {
                      _loadingIndex = 99;
                    });
                    var response = await dmodel.snapshotData();
                    if (response) {
                      snackbarStatus(context, "Successfully created snapshot!");
                    } else {
                      snackbarErr(context,
                          "There was an issue uploading your data to the cloud.");
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

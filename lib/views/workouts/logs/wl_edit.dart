// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class WLEdit extends StatefulWidget {
  const WLEdit({
    super.key,
    required this.wl,
    required this.onSave,
  });
  final WorkoutLog wl;
  final void Function(WorkoutLog wl) onSave;

  @override
  State<WLEdit> createState() => _WLEditState();
}

class _WLEditState extends State<WLEdit> {
  late WorkoutLog _wl;
  late int _hours;
  late int _minutes;
  late int _seconds;

  var _loading = false;

  @override
  void initState() {
    super.initState();
    _wl = widget.wl.copy();
    parseTime();
  }

  void parseTime() {
    var items = formatHHMMSS(_wl.duration, truncate: false).split(":");
    _hours = int.tryParse(items[0]) ?? 0;
    _minutes = int.tryParse(items[1]) ?? 0;
    _seconds = int.tryParse(items[2]) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "",
      leading: const [CancelButton()],
      children: [
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Field(
              labelText: "Title",
              value: _wl.title,
              charLimit: 100,
              showCharacters: true,
              hintText: "Chest and back",
              onChanged: (v) {
                setState(() {
                  _wl.title = v;
                });
              },
            ),
          ),
        ),
        Section(
          "Workout Duration",
          child: TimePicker(
            hours: _hours,
            minutes: _minutes,
            seconds: _seconds,
            showButtons: true,
            onChanged: (val) {
              setState(() {
                _wl.duration = val;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        WrappedButton(
          title: "Save Workout Log",
          type: WrappedButtonType.main,
          isLoading: _loading,
          onTap: () async {
            if (_wl.title.isEmpty) {
              snackbarErr(context, "Title cannot be empty");
              return;
            }
            setState(() {
              _loading = true;
            });
            try {
              var db = await DatabaseProvider().database;
              var r = await db.update(
                "workout_log",
                _wl.toMap(),
                where: "workoutLogId = ?",
                whereArgs: [_wl.workoutLogId],
              );
              if (r == 0) {
                throw "No items were changed in database";
              }
              widget.onSave(_wl);
              Navigator.of(context).pop();
            } catch (e) {
              print(e);
              NewrelicMobile.instance.recordError(
                e,
                StackTrace.current,
                attributes: {"err_code": "wl_save"},
              );
              snackbarErr(context, "There was an unknown error");
            }
            setState(() {
              _loading = true;
            });
          },
        )
      ],
    );
  }
}

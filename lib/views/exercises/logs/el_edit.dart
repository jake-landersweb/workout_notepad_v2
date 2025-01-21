import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_cell.dart';

class ELEdit extends StatefulWidget {
  const ELEdit({
    super.key,
    required this.log,
    required this.onSave,
  });
  final ExerciseLog log;
  final Function(ExerciseLog log) onSave;

  @override
  State<ELEdit> createState() => _ELEditState();
}

class _ELEditState extends State<ELEdit> {
  late List<ExerciseLogMeta> _meta;

  @override
  void initState() {
    super.initState();
    _meta = [];
    for (var i in widget.log.metadata) {
      _meta.add(ExerciseLogMeta.from(i));
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Edit Log",
      leading: const [CancelButton()],
      horizontalSpacing: 0,
      trailing: [
        Clickable(
          onTap: () {
            _onSave(context);
          },
          child: Text(
            "Save",
            style:
                ttLabel(context, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
      children: [
        for (int i = 0; i < _meta.length; i++) _cell(context, i),
      ],
    );
  }

  Widget _cell(BuildContext context, int i) {
    var m = _meta[i];
    return Column(
      children: [
        LaunchCellLog(
          index: 0,
          reps: m.reps,
          weight: m.weight,
          weightPost: m.weightPost,
          time: m.time,
          type: widget.log.type,
          tags: m.tags,
          onRepsChange: (v) {
            setState(() {
              m.reps = v;
            });
          },
          onWeightChange: (v) {
            setState(() {
              m.weight = v;
            });
          },
          onWeightPostChange: (v) {
            setState(() {
              m.weightPost = v;
            });
          },
          onTimeChange: (v) {
            setState(() {
              m.time = v;
            });
          },
          onSaved: (v) {
            setState(() {
              m.saved = v;
            });
          },
          onDelete: () {},
          onTagClick: (v) {
            if (m.tags.any((element) => element.tagId == v.tagId)) {
              m.tags.removeWhere((element) => element.tagId == v.tagId);
            } else {
              m.addTag(v);
            }
            setState(() {});
          },
          interactive: false,
        )
      ],
    );
  }

  Future<void> _onSave(BuildContext context) async {
    var db = await DatabaseProvider().database;

    try {
      await db.transaction((txn) async {
        // check for valid metadata
        if (_meta.isNotEmpty) {
          // insert the metadata
          for (var m in _meta) {
            await txn.insert(
              "exercise_log_meta",
              m.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );

            // remove duplicate tags based on tag id
            final seenTags = <String>{};
            List<ExerciseLogMetaTag> pruned = [];

            for (var item in m.tags) {
              if (seenTags.add(item.tagId)) {
                pruned.add(item);
              }
            }
            // insert tags
            for (var elmt in pruned) {
              await txn.insert(
                "exercise_log_meta_tag",
                elmt.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }
      });

      widget.log.metadata = _meta;
      widget.onSave(widget.log);
      Navigator.of(context).pop();
    } catch (e, stack) {
      logger.exception(e, stack);
      snackbarErr(context, "There was an issue updating the exercise log");
    }
  }
}

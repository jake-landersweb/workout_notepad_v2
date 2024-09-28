import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/raw_reorderable_list.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/data/workout_exercise.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class GraphsEdit extends StatefulWidget {
  const GraphsEdit({
    super.key,
    required this.logBuilders,
    required this.onSave,
  });
  final List<LogBuilder> logBuilders;
  final FutureOr<void> Function(List<LogBuilder> logBuilders) onSave;

  @override
  State<GraphsEdit> createState() => _GraphsEditState();
}

class _GraphsEditState extends State<GraphsEdit> {
  late List<LogBuilder> _lbs;

  @override
  void initState() {
    _lbs = [];
    for (var i in widget.logBuilders) {
      _lbs.add(i.copy());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Configure Graphs",
      horizontalSpacing: 0,
      leading: const [CloseButton2()],
      trailing: [
        Clickable(
          onTap: () async {
            var val = await _save();
            if (val.isNotEmpty) {
              snackbarErr(
                  context, "There was an issue saving your edits: $val");
            } else {
              await widget.onSave(_lbs);
              Navigator.of(context).pop();
            }
          },
          child: Text(
            "Save",
            style:
                ttLabel(context, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
      children: [
        _body(context),
      ],
    );
  }

  Widget _body(BuildContext context) {
    return RawReorderableList<LogBuilder>(
      items: _lbs,
      areItemsTheSame: (p0, p1) => p0.id == p1.id,
      header: const SizedBox(height: 16),
      footer: const SizedBox(height: 0),
      onReorderFinished: (item, from, to, newItems) {
        setState(() {
          _lbs = newItems;
        });
      },
      slideBuilder: (item, index) {
        return ActionPane(
          extentRatio: 0.3,
          motion: const DrawerMotion(),
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    SlidableAction(
                      borderRadius: BorderRadius.circular(10),
                      onPressed: (context) async {
                        await Future.delayed(
                          const Duration(milliseconds: 100),
                        );
                        setState(() {
                          _lbs.removeAt(index);
                        });
                      },
                      icon: LineIcons.alternateTrash,
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.error(),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      builder: (item, index, handle, inDrag) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: inDrag
                  ? item.backgroundColor == null
                      ? AppColors.cell(context)[50]
                      : getSwatch(item.backgroundColor!)[300]
                  : item.backgroundColor == null
                      ? AppColors.cell(context)
                      : item.backgroundColor!,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ColorUtil.random(item.graphType.name),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 30,
                      width: 30,
                      child: Center(
                        child: Icon(
                          item.graphType.getIcon(),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.graphTitle, style: ttBody(context)),
                        ],
                      ),
                    ),
                    handle,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String> _save() async {
    try {
      var db = await DatabaseProvider().database;
      await db.transaction((txn) async {
        // delete all of the graph items
        await txn.rawDelete("DELETE FROM custom_log_builder");

        // enumerate through the items and add them to the database
        // using the index as the sortOrder field.
        for (int i = 0; i < _lbs.length; i++) {
          _lbs[i].sortIndex = i;
          await txn.insert("custom_log_builder", _lbs[i].toPayload());
        }
      });
      return "";
    } catch (e, stack) {
      NewrelicMobile.instance.recordError(e, stack, attributes: {
        "title": "There was an issue saving the edited graph items."
      });
      print(e);
      print(stack);
      return e.toString();
    }
  }
}

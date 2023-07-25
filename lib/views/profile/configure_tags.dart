import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sql.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ConfigureTags extends StatefulWidget {
  const ConfigureTags({
    super.key,
    required this.tags,
  });
  final List<Tag> tags;

  @override
  State<ConfigureTags> createState() => _ConfigureTagsState();
}

class _ConfigureTagsState extends State<ConfigureTags> {
  late List<Tag> _tags;
  bool _isLoading = false;

  @override
  void initState() {
    _tags = [for (var i in widget.tags) i.clone()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Configure Tags",
      leading: const [CloseButton2()],
      trailing: [
        _isLoading
            ? const LoadingIndicator()
            : Clickable(
                onTap: () => _onSave(context),
                child: Text(
                  "Save",
                  style: ttLabel(
                    context,
                    color: _isValid()
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.subtext(context),
                  ),
                ),
              ),
      ],
      children: [
        const SizedBox(height: 16),
        Section(
          "Default - ${_tags.firstWhereOrNull((element) => element.isDefault)?.title ?? 'None'} ",
          child: ContainedList<Tag>(
            children: _tags,
            leadingPadding: 0,
            trailingPadding: 0,
            childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            childBuilder: (context, item, index) {
              return _cell(context, item);
            },
          ),
        )
      ],
    );
  }

  Widget _cell(BuildContext context, Tag tag) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (tag.isDefault) {
              for (var e in _tags) {
                e.isDefault = false;
              }
              setState(() {});
            } else {
              for (var e in _tags) {
                e.isDefault = false;
              }
              setState(() {
                tag.isDefault = true;
              });
            }
          },
          child: Icon(
            tag.isDefault ? Icons.check_box : Icons.check_box_outline_blank,
            color: tag.isDefault
                ? Theme.of(context).colorScheme.primary
                : AppColors.cell(context)[600],
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Field(
            labelText: "title",
            value: tag.title,
            isLabeled: false,
            onChanged: (v) {
              setState(() {
                tag.title = v;
              });
            },
          ),
        ),
      ],
    );
  }

  bool _isValid() {
    return !_tags.any((element) => element.title.isEmpty);
  }

  Future<void> _onSave(BuildContext context) async {
    if (!_isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Titles cannot be empty"),
          backgroundColor: Colors.red[300],
        ),
      );
      return;
    }
    try {
      var db = await getDB();
      await db.transaction((txn) async {
        for (var i in _tags) {
          await txn.insert(
            "tag",
            i.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      var dmodel = context.read<DataModel>();
      await dmodel.fetchData();
      await NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "tag_configure",
        eventAttributes: {
          "length": _tags.length,
        },
      );
      Navigator.of(context).pop();
    } catch (e) {
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "tag_save"},
      );
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("There was an issue updating the tags"),
          backgroundColor: Colors.red[300],
        ),
      );
    }
  }
}

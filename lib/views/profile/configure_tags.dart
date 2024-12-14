import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sql.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

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
      horizontalSpacing: 0,
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
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
            child: Text(
              "Default - ${_tags.firstWhereOrNull((element) => element.isDefault)?.title ?? 'None'} ",
              textAlign: TextAlign.start,
              style: ttcaption(context),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: RawReorderableList<Tag>(
                  items: _tags,
                  areItemsTheSame: (p0, p1) => p0.tagId == p1.tagId,
                  onReorderFinished: (item, from, to, newItems) {
                    setState(() {
                      _tags
                        ..clear()
                        ..addAll(newItems);
                    });
                  },
                  // slideBuilder: (item, index) {
                  //   return ActionPane(
                  //     extentRatio: 0.3,
                  //     motion: const DrawerMotion(),
                  //     children: [
                  //       Expanded(
                  //         child: Row(children: [
                  //           SlidableAction(
                  //             onPressed: (context) async {
                  //               await Future.delayed(
                  //                 const Duration(milliseconds: 100),
                  //               );
                  //               setState(() {
                  //                 _tags.removeAt(index);
                  //               });
                  //             },
                  //             icon: LineIcons.alternateTrash,
                  //             label: "Delete",
                  //             foregroundColor:
                  //                 Theme.of(context).colorScheme.onError,
                  //             backgroundColor:
                  //                 Theme.of(context).colorScheme.error,
                  //           ),
                  //         ]),
                  //       ),
                  //     ],
                  //   );
                  // },
                  builder: (item, index, handle, inDrag) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: inDrag
                              ? AppColors.cell(context)[100]
                              : AppColors.cell(context),
                          borderRadius: BorderRadius.only(
                              topLeft: index == 0
                                  ? const Radius.circular(10)
                                  : const Radius.circular(0),
                              bottomLeft: index == _tags.length - 1
                                  ? const Radius.circular(10)
                                  : const Radius.circular(0)),
                        ),
                        child: _cell(context, item, handle),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: WrappedButton(
            title: "Add a New Tag",
            type: WrappedButtonType.main,
            onTap: () {
              setState(() {
                _tags.add(Tag.init(title: ""));
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _cell(BuildContext context, Tag tag, Handle handle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
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
              // color: tag.isDefault
              //     ? Theme.of(context).colorScheme.primary
              //     : AppColors.cell(context)[600],
              color: ColorUtil.random(tag.title),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Field(
              labelText: "Title",
              value: tag.title,
              isLabeled: false,
              onChanged: (v) {
                setState(() {
                  tag.title = v;
                });
              },
            ),
          ),
          handle,
        ],
      ),
    );
  }

  bool _isValid() {
    return !_tags.any((element) => element.title.isEmpty);
  }

  Future<void> _onSave(BuildContext context) async {
    if (!_isValid()) {
      snackbarErr(context, "Titles cannot be empty.");
      return;
    }
    try {
      var db = await DatabaseProvider().database;
      await db.transaction((txn) async {
        await txn.rawDelete("DELETE FROM tag");
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
      snackbarErr(context, "There was an issue updating the tags.");
    }
  }
}

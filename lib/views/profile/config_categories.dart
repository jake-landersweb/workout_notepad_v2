import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ConfigureCategories extends StatefulWidget {
  const ConfigureCategories({
    super.key,
    required this.categories,
  });
  final List<Category> categories;

  @override
  State<ConfigureCategories> createState() => _ConfigureCategoriesState();
}

class _ConfigureCategoriesState extends State<ConfigureCategories> {
  bool _isLoading = false;
  late List<Category> _categories;

  @override
  void initState() {
    _categories = [for (var i in widget.categories) i.copy()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return comp.HeaderBar.sheet(
      title: "Categories",
      leading: const [comp.CloseButton2()],
      horizontalSpacing: 0,
      trailing: [
        _isLoading
            ? const comp.LoadingIndicator()
            : comp.Clickable(
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
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: comp.RawReorderableList<Category>(
                  items: _categories,
                  areItemsTheSame: (p0, p1) => p0.categoryId == p1.categoryId,
                  onReorderFinished: (item, from, to, newItems) {
                    setState(() {
                      _categories
                        ..clear()
                        ..addAll(newItems);
                    });
                  },
                  slideBuilder: (item, index) {
                    return ActionPane(
                      extentRatio: 0.3,
                      motion: const DrawerMotion(),
                      children: [
                        Expanded(
                          child: Row(children: [
                            SlidableAction(
                              onPressed: (context) async {
                                await Future.delayed(
                                  const Duration(milliseconds: 100),
                                );
                                setState(() {
                                  _categories.removeAt(index);
                                });
                              },
                              icon: LineIcons.alternateTrash,
                              label: "Delete",
                              foregroundColor:
                                  Theme.of(context).colorScheme.onError,
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          ]),
                        ),
                      ],
                    );
                  },
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
                              bottomLeft: index == _categories.length - 1
                                  ? const Radius.circular(10)
                                  : const Radius.circular(0)),
                        ),
                        child: _itemCell(context, item, handle),
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
            title: "Add a New Category",
            type: WrappedButtonType.main,
            onTap: () {
              cupertinoSheet(
                context: context,
                builder: (context) => CreateCategory(
                  categories: _categories.map((e) => e.title).toList(),
                  onCompletion: (val, icon) {
                    setState(() {
                      _categories.add(
                        Category.init(title: val, icon: icon),
                      );
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _itemCell(BuildContext context, Category item, Handle handle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
      child: Row(
        children: [
          comp.Clickable(
            onTap: () {
              showIconPicker(
                context: context,
                initialIcon: item.icon,
                closeOnSelection: true,
                onSelection: (icon) {
                  setState(() {
                    item.icon = icon;
                  });
                },
              );
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                getImageIcon(item.icon, size: 50),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cell(context)[700],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.edit_rounded,
                      color: AppColors.cell(context),
                      size: 18,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: comp.Field(
                labelText: "Title",
                value: item.title.capitalize(),
                isLabeled: false,
                onChanged: (val) {
                  setState(() {
                    item.title = val;
                  });
                },
              ),
            ),
          ),
          handle,
        ],
      ),
    );
  }

  bool _isValid() {
    if (_categories.any((element) => element.title.isEmpty)) {
      return false;
    }
    return true;
  }

  Future<void> _onSave(BuildContext context) async {
    try {
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
        });
        var dmodel = context.read<DataModel>();
        var db = await getDB();
        await db.transaction((txn) async {
          await txn.delete("category");
          for (var i in _categories) {
            await txn.insert("category", i.toMap());
          }
        });
        await dmodel.fetchData();
        setState(() {
          _isLoading = false;
        });
        await NewrelicMobile.instance.recordCustomEvent(
          "WN_Metric",
          eventName: "category_configure",
          eventAttributes: {
            "length": _categories.length,
          },
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "category_save"},
      );
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "There was an issue saving your categories",
        ),
        backgroundColor: Colors.red[300],
      ));
    }
  }
}

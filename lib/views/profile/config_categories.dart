import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';

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
      horizontalSpacing: 0,
      leading: const [comp.CloseButton()],
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
        comp.ContainedList<Category>(
          children: _categories,
          allowsDelete: true,
          onDelete: (context, item, index) {
            setState(() {
              _categories.removeAt(index);
            });
          },
          childBuilder: (context, item, index) {
            return Row(
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
                      Icon(
                        Icons.edit,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.cell(context)[600]!,
                          ),
                        ),
                      ),
                      child: comp.Field(
                        labelText: "Title",
                        value: item.title,
                        isLabeled: false,
                        onChanged: (val) {
                          setState(() {
                            item.title = val;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  bool _isValid() {
    if (_categories.any((element) => element.title.isEmpty)) {
      return false;
    }
    return true;
  }

  Future<void> _onSave(BuildContext context) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      var dmodel = context.read<DataModel>();
      var db = await getDB();
      await db.rawQuery("DELETE FROM category");
      for (var i in _categories) {
        await i.insert();
      }
      await dmodel.fetchData();
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }
}

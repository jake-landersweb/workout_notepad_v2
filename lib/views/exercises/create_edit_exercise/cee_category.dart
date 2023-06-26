import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/cell_wrapper.dart';
import 'package:workout_notepad_v2/components/field.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';

class CreateCategory extends StatefulWidget {
  const CreateCategory({
    super.key,
    required this.categories,
    required this.onCompletion,
    this.onCancel,
  });
  final List<String> categories;
  final void Function(String val, String icon) onCompletion;
  final VoidCallback? onCancel;

  @override
  State<CreateCategory> createState() => ECreateCategoryState();
}

class ECreateCategoryState extends State<CreateCategory> {
  String _category = "";
  String _icon = "";

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Create Category",
      leading: const [comp.CancelButton()],
      children: [
        const SizedBox(height: 16),
        Clickable(
          onTap: () => showIconPicker(
              context: context,
              initialIcon: "none",
              closeOnSelection: true,
              onSelection: (icon) {
                setState(() {
                  _icon = icon;
                });
              }),
          child: Column(
            children: [
              getImageIcon(_icon, size: 100),
              Text(
                "Edit",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CellWrapper(
          child: Field(
            labelText: "Category",
            hintText: "Category (ex. Arms)",
            charLimit: 20,
            showCharacters: true,
            onChanged: (val) {
              setState(() {
                _category = val.toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _isValid()
              ? () {
                  widget.onCompletion(
                    _category.toLowerCase(),
                    _icon,
                  );
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text("Add"),
        ),
      ],
    );
  }

  bool _isValid() {
    if (_category.isEmpty) {
      return false;
    }
    if (widget.categories.contains(_category.toLowerCase())) {
      return false;
    }
    return true;
  }
}

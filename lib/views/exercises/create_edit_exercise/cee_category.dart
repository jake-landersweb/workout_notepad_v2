import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/floating_sheet.dart';
import 'package:workout_notepad_v2/components/cell_wrapper.dart';
import 'package:workout_notepad_v2/components/field.dart';

import 'package:workout_notepad_v2/model/root.dart';
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
    var dmodel = context.read<DataModel>();
    return FloatingSheet(
      title: "Create Category",
      child: Column(
        children: [
          const SizedBox(height: 16),
          Clickable(
            onTap: () => showIconPicker(
                context: context,
                initialIcon: _icon,
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
                    color: AppColors.subtext(context),
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
          Clickable(
            onTap: _isValid()
                ? () {
                    widget.onCompletion(
                      _category.toLowerCase(),
                      _icon,
                    );
                    Navigator.of(context).pop();
                  }
                : () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: dmodel.color,
              ),
              height: 40,
              width: double.infinity,
              child: const Center(
                child: Text(
                  "Add",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
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

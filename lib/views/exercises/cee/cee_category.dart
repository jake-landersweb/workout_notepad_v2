import 'package:flutter/material.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

class CreateCategory extends StatefulWidget {
  const CreateCategory({
    super.key,
    required this.categories,
    required this.onCompletion,
    this.onCancel,
  });
  final List<String> categories;
  final void Function(String val) onCompletion;
  final VoidCallback? onCancel;

  @override
  State<CreateCategory> createState() => ECreateCategoryState();
}

class ECreateCategoryState extends State<CreateCategory> {
  String _category = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sui.CellWrapper(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: sui.TextField(
            labelText: "Category",
            hintText: "Category (ex. Arms)",
            charLimit: 20,
            showCharacters: true,
            onChanged: (val) {
              setState(() {
                _category = val;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        comp.ActionButton(
          title: "Add",
          isValid: _isValid(),
          onTap: () {
            widget.onCompletion(_category.toLowerCase());
            Navigator.of(context).pop();
          },
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

import 'package:flutter/material.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/text_themes.dart';

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
    return sui.AppBar.sheet(
      title: "Create Category",
      leading: const [comp.CancelButton()],
      children: [
        const SizedBox(height: 16),
        sui.CellWrapper(
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
        FilledButton(
          onPressed: _isValid()
              ? () {
                  widget.onCompletion(_category.toLowerCase());
                  Navigator.of(context).pop();
                }
              : null,
          child: Text("Add"),
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

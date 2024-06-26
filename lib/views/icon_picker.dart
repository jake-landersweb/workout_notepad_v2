import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/dynamicgv.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/utils/root.dart';

void showIconPicker({
  required BuildContext context,
  String initialIcon = "bench-press",
  required Function(String icon) onSelection,
  bool closeOnSelection = false,
}) {
  comp.cupertinoSheet(
    context: context,
    builder: (context) => HeaderBar.sheet(
      title: "",
      leading: const [comp.CloseButton2()],
      children: [
        _IconPicker(
          onSelection: onSelection,
          initialIcon: initialIcon,
          closeOnSelection: closeOnSelection,
        ),
      ],
    ),
  );
}

class _IconPicker extends StatefulWidget {
  const _IconPicker({
    this.initialIcon = "bench-press",
    required this.onSelection,
    this.closeOnSelection = false,
  });
  final String initialIcon;
  final Function(String icon) onSelection;
  final bool closeOnSelection;

  @override
  State<_IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<_IconPicker> {
  late List<String> _icons;
  late String _selected;

  @override
  void initState() {
    _icons = getAllIconNames();
    _selected = widget.initialIcon;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicGridView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _icons.length,
      crossAxisCount: 4,
      builder: (context, index) {
        return _iconCell(context, _icons[index]);
      },
    );
  }

  Widget _iconCell(BuildContext context, String name) {
    return Clickable(
      onTap: () {
        setState(() {
          _selected = name;
        });
        widget.onSelection(name);
        if (widget.closeOnSelection) {
          Navigator.of(context).pop();
        }
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: name == _selected ? AppColors.cell(context) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: getImageIcon(name),
          ),
        ),
      ),
    );
  }
}

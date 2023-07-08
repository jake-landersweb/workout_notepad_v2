import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'floating_sheet.dart' as cv;

void showSheetSelector<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required T initialItem,
  required Function(BuildContext context, int index, T item) onSelect,
  String Function(BuildContext context, T item)? titleBuilder,
  bool closeOnSelect = true,
}) {
  showFloatingSheet(
    context: context,
    builder: (context) => SheetSelector<T>(
      title: title,
      items: items,
      initialItem: initialItem,
      onSelect: onSelect,
      titleBuilder: titleBuilder,
      closeOnSelect: closeOnSelect,
    ),
  );
}

class SheetSelector<T> extends StatefulWidget {
  const SheetSelector({
    super.key,
    required this.title,
    required this.items,
    required this.initialItem,
    required this.onSelect,
    this.titleBuilder,
    this.closeOnSelect = true,
  });
  final String title;
  final List<T> items;
  final T initialItem;
  final Function(BuildContext context, int index, T item) onSelect;
  final String Function(BuildContext context, T item)? titleBuilder;
  final bool closeOnSelect;

  @override
  State<SheetSelector<T>> createState() => _SheetSelectorState<T>();
}

class _SheetSelectorState<T> extends State<SheetSelector<T>> {
  late T _selected;

  @override
  void initState() {
    _selected = widget.initialItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return cv.FloatingSheet(
      title: widget.title,
      child: Column(
        children: [
          for (int i = 0; i < widget.items.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == widget.items.length - 1 ? 0 : 8,
              ),
              child: _cell(context, i),
            ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, int index) {
    return Clickable(
      onTap: () {
        setState(() {
          _selected = widget.items[index];
          widget.onSelect(context, index, widget.items[index]);
        });
        if (widget.closeOnSelect) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selected == widget.items[index]
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : null,
          border: _selected == widget.items[index]
              ? null
              : Border.all(color: AppColors.divider(context)),
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            widget.titleBuilder == null
                ? widget.items[index].toString()
                : widget.titleBuilder!(
                    context,
                    widget.items[index],
                  ),
            style: TextStyle(
              color: _selected == widget.items[index]
                  ? Theme.of(context).colorScheme.primary
                  : AppColors.subtext(context),
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

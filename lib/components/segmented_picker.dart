import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/root.dart';

class SegmentedPickerStyle {
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final Color? pickerColor;
  final ShapeBorder? shape;
  final FontWeight? selectedWeight;

  const SegmentedPickerStyle({
    this.height = 33,
    this.backgroundColor,
    this.textColor,
    this.selectedTextColor,
    this.pickerColor,
    this.shape,
    this.selectedWeight,
  });
}

class SegmentedPicker<T> extends StatefulWidget {
  const SegmentedPicker({
    Key? key,
    required this.titles,
    this.selections,
    required this.onSelection,
    required this.selection,
    this.style = const SegmentedPickerStyle(),
  })  : assert(titles.length < 4),
        super(key: key);
  final List<String> titles;
  final List<T>? selections;
  final Function(dynamic) onSelection;
  final T selection;
  final SegmentedPickerStyle style;

  @override
  _SegmentedPickerState createState() => _SegmentedPickerState();
}

class _SegmentedPickerState extends State<SegmentedPicker> {
  bool _showSelector = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: widget.style.shape ??
          ContinuousRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: widget.style.backgroundColor ??
          Theme.of(context).colorScheme.surfaceVariant,
      child: SizedBox(
        height: widget.style.height + 2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
          child: Stack(
            alignment: _alignment(),
            children: [
              AnimatedAlign(
                alignment: _alignment(),
                curve: Sprung.overDamped,
                duration: const Duration(milliseconds: 650),
                child: Material(
                  shape: widget.style.shape ??
                      ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                  color: widget.style.pickerColor ??
                      Theme.of(context).primaryColor.withOpacity(0.3),
                  child: FractionallySizedBox(
                    widthFactor: 1 / widget.titles.length,
                    child: SizedBox(height: widget.style.height),
                  ),
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < widget.titles.length; i++)
                    Expanded(
                      child: Clickable(
                        onTap: () => _handleTap(i),
                        child: Align(
                          alignment: AlignmentDirectional.center,
                          child: Text(
                            widget.titles[i],
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: _fontWeight(i, context),
                              color: _titleColor(i, context),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _titleColor(int i, BuildContext context) {
    if (widget.selections != null) {
      if (widget.selections![i] == widget.selection) {
        return widget.style.selectedTextColor ?? Theme.of(context).primaryColor;
      } else {
        return widget.style.textColor ?? _textColor(context);
      }
    } else {
      if (widget.titles[i] == widget.selection) {
        return widget.style.selectedTextColor ?? Theme.of(context).primaryColor;
      } else {
        return widget.style.textColor ?? _textColor(context);
      }
    }
  }

  FontWeight _fontWeight(int i, BuildContext context) {
    if (widget.selections != null) {
      if (widget.selections![i] == widget.selection) {
        return widget.style.selectedWeight ?? FontWeight.w600;
      } else {
        return FontWeight.w400;
      }
    } else {
      if (widget.titles[i] == widget.selection) {
        return widget.style.selectedWeight ?? FontWeight.w600;
      } else {
        return FontWeight.w400;
      }
    }
  }

  AlignmentGeometry _alignment() {
    if (widget.selections != null) {
      if (widget.selections!.contains(widget.selection)) {
        if (widget.selections!.first == widget.selection) {
          return AlignmentDirectional.centerStart;
        } else if (widget.selections!.last == widget.selection) {
          return AlignmentDirectional.centerEnd;
        } else {
          return AlignmentDirectional.center;
        }
      } else {
        _showSelector = false;
        return AlignmentDirectional.center;
      }
    } else {
      if (widget.titles.contains(widget.selection)) {
        if (widget.selections != null) {
          if (widget.selections!.first == widget.selection) {
            return AlignmentDirectional.centerStart;
          } else if (widget.selections!.last == widget.selection) {
            return AlignmentDirectional.centerEnd;
          } else {
            return AlignmentDirectional.center;
          }
        } else {
          if (widget.titles.first == widget.selection) {
            return AlignmentDirectional.centerStart;
          } else if (widget.titles.last == widget.selection) {
            return AlignmentDirectional.centerEnd;
          } else {
            return AlignmentDirectional.center;
          }
        }
      } else {
        _showSelector = false;
        return AlignmentDirectional.center;
      }
    }
  }

  void _handleTap(int index) {
    // send correct feedback to parent
    widget.onSelection(widget.selections != null
        ? widget.selections![index]
        : widget.titles[index]);
  }

  Color _textColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}

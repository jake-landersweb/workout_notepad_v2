import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';

import 'dart:math' as math;

import 'package:workout_notepad_v2/components/field.dart';
import 'package:workout_notepad_v2/components/root.dart';

class NumberPicker extends StatefulWidget {
  const NumberPicker({
    super.key,
    required this.onChanged,
    this.intialValue,
    this.textFontSize = 60,
    this.buttonTextSize = 22,
    this.fontWeight = FontWeight.w600,
    this.maxValue = 999,
    this.minValue = 0,
    this.showPicker = true,
    this.topButtonChild,
    this.bottomButtonChild,
    this.onTopClick,
    this.onBottomClick,
    this.picker,
    this.spacing = 16,
  });
  final Function(int val) onChanged;
  final int? intialValue;
  final double textFontSize;
  final double buttonTextSize;
  final FontWeight fontWeight;
  final int maxValue;
  final int minValue;
  final bool showPicker;
  final Widget? topButtonChild;
  final Widget? bottomButtonChild;
  final VoidCallback? onTopClick;
  final VoidCallback? onBottomClick;
  final Widget? picker;
  final double spacing;

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller =
        TextEditingController(text: widget.intialValue?.toString() ?? "0");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Field(
                    controller: _controller,
                    labelText: "",
                    showBackground: false,
                    fieldPadding: EdgeInsets.zero,
                    textAlign: TextAlign.center,
                    isLabeled: false,
                    keyboardType: TextInputType.number,
                    charLimit: getNumChars(),
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _TextInputFormatter(
                          maxValue: widget.maxValue, minValue: widget.minValue),
                    ],
                    style: TextStyle(
                      fontSize: widget.textFontSize,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: widget.fontWeight,
                    ),
                    onChanged: (val) {
                      if (val != "") {
                        int? tmp = int.tryParse(val);
                        if (tmp != null) {
                          widget.onChanged(tmp);
                        }
                      }
                    },
                  ),
                ),
              ),
              if (widget.showPicker)
                Padding(
                  padding: EdgeInsets.only(left: widget.spacing),
                  child: widget.picker == null
                      ? SizedBox(
                          width: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Column(
                                children: [
                                  _plusMinusCell(
                                    context,
                                    getColor(true),
                                    getAccent(true),
                                    true,
                                    child: widget.topButtonChild,
                                    onTap: widget.onBottomClick,
                                  ),
                                  _plusMinusCell(
                                    context,
                                    getColor(false),
                                    getAccent(false),
                                    false,
                                    child: widget.bottomButtonChild,
                                    onTap: widget.onBottomClick,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : widget.picker!,
                )
            ],
          ),
        ),
      ],
    );
  }

  int getNumChars() {
    return widget.maxValue.toString().length;
  }

  Color getColor(bool plus) {
    if (plus) {
      return Theme.of(context).colorScheme.onTertiaryContainer;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Color getAccent(bool plus) {
    if (plus) {
      return Theme.of(context).colorScheme.tertiaryContainer;
    } else {
      return Theme.of(context).colorScheme.surfaceVariant;
    }
  }

  Widget _plusMinusCell(
    BuildContext context,
    Color textColor,
    Color backgroundColor,
    bool isPlus, {
    Widget? child,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Clickable(
        onTap: () {
          if (onTap != null) {
            onTap();
          } else {
            if (isPlus) {
              int? tmp = int.tryParse(_controller.text);
              if (tmp != null) {
                tmp += 1;
                if (tmp > widget.maxValue) {
                  tmp = widget.maxValue;
                }
                widget.onChanged(tmp);
                setState(() {
                  _controller.text = tmp.toString();
                });
              }
            } else {
              int? tmp = int.tryParse(_controller.text);
              if (tmp != null) {
                tmp -= 1;
                if (tmp < widget.minValue) {
                  tmp = widget.minValue;
                }
                widget.onChanged(tmp);
                setState(() {
                  _controller.text = tmp.toString();
                });
              }
            }
          }
        },
        child: Container(
          color: backgroundColor,
          width: double.infinity,
          child: Center(
            child: child ??
                Icon(
                  isPlus ? LineIcons.plus : LineIcons.minus,
                  color: textColor,
                ),
          ),
        ),
      ),
    );
  }
}

class _TextInputFormatter extends TextInputFormatter {
  late int maxValue;
  late int minValue;

  _TextInputFormatter({
    required this.maxValue,
    required this.minValue,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String value = newValue.text;

    if (value.isEmpty) {
      value = "0";
    }

    int? tmp = int.tryParse(value);

    if (tmp == null) {
      return oldValue;
    }

    if (tmp > maxValue) {
      tmp = maxValue;
    }
    if (tmp < minValue) {
      tmp = minValue;
    }

    String newText = tmp.toString();

    newSelection = newValue.selection.copyWith(
      baseOffset: math.min(newText.length, newText.length),
      extentOffset: math.min(newText.length, newText.length),
    );

    return TextEditingValue(
      text: newText,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}

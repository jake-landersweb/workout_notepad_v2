import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'dart:math' as math;

class TimePicker extends StatefulWidget {
  TimePicker({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.onChanged,
    this.label,
  });

  TimePicker.fromExercise(
    ExerciseBase exercise, {
    super.key,
    required this.onChanged,
    this.label,
  }) {
    hours = exercise.getHours();
    minutes = exercise.getMinutes();
    seconds = exercise.getSeconds();
  }

  late int hours;
  late int minutes;
  late int seconds;
  late Function(int val) onChanged;
  String? label;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late int _hours;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    _hours = widget.hours;
    _minutes = widget.minutes;
    _seconds = widget.seconds;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Row(
            children: [
              Expanded(
                child: NumberPicker(
                  minValue: 0,
                  intialValue: _hours,
                  initialValueStr: _hours < 10 ? "0$_hours" : _hours.toString(),
                  textFontSize: 40,
                  showPicker: false,
                  maxValue: 99,
                  contain: false,
                  spacing: 8,
                  customFormatter:
                      _TextInputFormatter(maxValue: 99, minValue: 0),
                  onChanged: (val) {
                    setState(() {
                      _hours = val;
                    });
                    widget.onChanged(_getSeconds());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  ":",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: NumberPicker(
                  minValue: 0,
                  intialValue: _minutes,
                  initialValueStr:
                      _minutes < 10 ? "0$_minutes" : _minutes.toString(),
                  textFontSize: 40,
                  showPicker: false,
                  customFormatter:
                      _TextInputFormatter(maxValue: 59, minValue: 0),
                  maxValue: 59,
                  contain: false,
                  spacing: 8,
                  onChanged: (val) {
                    setState(() {
                      _minutes = val;
                    });
                    widget.onChanged(_getSeconds());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  ":",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: NumberPicker(
                  minValue: 0,
                  intialValue: _seconds,
                  initialValueStr:
                      _seconds < 10 ? "0$_seconds" : _seconds.toString(),
                  textFontSize: 40,
                  contain: false,
                  customFormatter:
                      _TextInputFormatter(maxValue: 59, minValue: 0),
                  showPicker: false,
                  maxValue: 59,
                  spacing: 8,
                  onChanged: (val) {
                    setState(() {
                      _seconds = val;
                    });
                    widget.onChanged(_getSeconds());
                  },
                ),
              ),
            ],
          ),
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                widget.label!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _getSeconds() {
    return Duration(
      hours: _hours,
      minutes: _minutes,
      seconds: _seconds,
    ).inSeconds;
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
      value = "00";
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
    if (tmp < 10) {
      newText = "0$newText";
    }

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

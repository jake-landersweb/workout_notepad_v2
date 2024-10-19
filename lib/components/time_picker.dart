import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'dart:math' as math;

import 'package:workout_notepad_v2/utils/root.dart';

// ignore: must_be_immutable
class TimePicker extends StatefulWidget {
  TimePicker({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.onChanged,
    this.showButtons = false,
    this.label,
  });

  TimePicker.fromExercise(
    Exercise exercise, {
    super.key,
    required this.onChanged,
    this.showButtons = false,
    this.label,
  }) {
    hours = exercise.getHours();
    minutes = exercise.getMinutes();
    seconds = exercise.getSeconds();
  }

  TimePicker.fromSeconds({
    super.key,
    required int seconds,
    required this.onChanged,
    this.showButtons = false,
    this.label,
  }) {
    this.hours = seconds ~/ 3600;
    this.minutes = (seconds % 3600) ~/ 60;
    this.seconds = seconds % 60;
  }

  late int hours;
  late int minutes;
  late int seconds;
  late bool showButtons;
  late Function(int val) onChanged;
  String? label;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late int _hours;
  late int _minutes;
  late int _seconds;
  late ValueKey _hourKey;
  late ValueKey _minKey;
  late ValueKey _secKey;

  @override
  void initState() {
    _hours = widget.hours;
    _minutes = widget.minutes;
    _seconds = widget.seconds;
    _setKeys();
    super.initState();
  }

  void _setKeys() {
    var uuid = const Uuid();
    _hourKey = ValueKey(uuid.v4());
    _minKey = ValueKey(uuid.v4());
    _secKey = ValueKey(uuid.v4());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              Row(
                children: [
                  Expanded(
                    child: NumberPicker(
                      key: _hourKey,
                      minValue: 0,
                      intialValue: _hours,
                      initialValueStr:
                          _hours < 10 ? "0$_hours" : _hours.toString(),
                      textFontSize: 30,
                      showPicker: false,
                      maxValue: 99,
                      contain: false,
                      spacing: 8,
                      customFormatter:
                          TimeInputFormatter(maxValue: 99, minValue: 0),
                      onChanged: (val) {
                        setState(() {
                          _hours = val as int;
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
                        color: AppColors.subtext(context),
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: NumberPicker(
                      key: _minKey,
                      minValue: 0,
                      intialValue: _minutes,
                      initialValueStr:
                          _minutes < 10 ? "0$_minutes" : _minutes.toString(),
                      textFontSize: 30,
                      showPicker: false,
                      customFormatter:
                          TimeInputFormatter(maxValue: 59, minValue: 0),
                      maxValue: 59,
                      contain: false,
                      spacing: 8,
                      onChanged: (val) {
                        setState(() {
                          _minutes = val as int;
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
                        color: AppColors.subtext(context),
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: NumberPicker(
                      key: _secKey,
                      minValue: 0,
                      intialValue: _seconds,
                      initialValueStr:
                          _seconds < 10 ? "0$_seconds" : _seconds.toString(),
                      textFontSize: 30,
                      contain: false,
                      customFormatter:
                          TimeInputFormatter(maxValue: 59, minValue: 0),
                      showPicker: false,
                      maxValue: 59,
                      spacing: 8,
                      onChanged: (val) {
                        setState(() {
                          _seconds = val as int;
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
        ),
        if (widget.showButtons)
          Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Clickable(
                      onTap: () {
                        var total =
                            (_hours * 3600) + (_minutes * 60) + _seconds;
                        if (total <= 600) {
                          total = 0;
                        } else {
                          total -= 600;
                        }
                        var items =
                            formatHHMMSS(total, truncate: false).split(":");
                        _hours = int.parse(items[0]);
                        _minutes = int.parse(items[1]);
                        _seconds = int.parse(items[2]);
                        _setKeys();
                        widget.onChanged(_getSeconds());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cell(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 40,
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.remove_rounded),
                              Text("10 min"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Clickable(
                      onTap: () {
                        var total =
                            (_hours * 3600) + (_minutes * 60) + _seconds;
                        total += 600;
                        var items =
                            formatHHMMSS(total, truncate: false).split(":");
                        _hours = int.parse(items[0]);
                        _minutes = int.parse(items[1]);
                        _seconds = int.parse(items[2]);
                        _setKeys();
                        widget.onChanged(_getSeconds());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 40,
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                              ),
                              Text(
                                "10 min",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
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

class TimeInputFormatter extends TextInputFormatter {
  late int maxValue;
  late int minValue;

  TimeInputFormatter({
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

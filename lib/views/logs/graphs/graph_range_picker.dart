import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/colored_cell.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_date.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class GraphRangeProvider extends ChangeNotifier {
  late LogBuilderDate _date;

  GraphRangeProvider({
    LogBuilderDate? date,
  }) {
    _date = date ?? LogBuilderDate();
  }

  void setDate(LogBuilderDate date) {
    _date = date;
    notifyListeners();
  }

  LogBuilderDate get getDate => _date;
}

class GraphRangeView extends StatelessWidget {
  const GraphRangeView({
    super.key,
    required this.date,
    required this.onSave,
  });
  final LogBuilderDate date;
  final Function(BuildContext context, LogBuilderDate date) onSave;

  @override
  Widget build(BuildContext context) {
    return WrappedButton(
      title: date.toString(),
      center: true,
      height: 30,
      backgroundColor: AppColors.divider(context),
      onTap: () {
        showFloatingSheet(
          context: context,
          builder: (context) {
            return GraphRangePicker(
              date: date,
              onSave: onSave,
            );
          },
        );
      },
    );
  }
}

class GraphRangePicker extends StatefulWidget {
  const GraphRangePicker({
    super.key,
    this.date,
    required this.onSave,
  });
  final LogBuilderDate? date;
  final Function(BuildContext context, LogBuilderDate date) onSave;

  @override
  State<GraphRangePicker> createState() => _GraphRangePickerState();
}

class _GraphRangePickerState extends State<GraphRangePicker> {
  late LogBuilderDate _date;
  late Tuple2<DateTime, DateTime> _range;

  @override
  void initState() {
    _date = widget.date?.copy() ?? LogBuilderDate();
    _range = _date.getRange();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSheet(
      title: "Date Range",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ColoredCell(
              title:
                  "${formatDateTime(_range.v1)} - ${formatDateTime(_range.v2)}",
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i in LBDateRange.values)
                ColoredCell(
                  title: i.name,
                  on: _date.dateRangeType == i,
                  onTap: () {
                    setState(() {
                      _date.dateRangeType = i;
                      if ([LBDateRange.MONTH, LBDateRange.WEEK].contains(i)) {
                        _range = _date.getRange();
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 114,
            child: Column(
              children: [
                Expanded(child: _body(context)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WrappedButton(
            title: "Save",
            center: true,
            type: WrappedButtonType.main,
            onTap: () {
              if (_date.dateRangeType == LBDateRange.CUSTOM) {
                _date.rangeStart = _range.v1;
                _date.rangeEnd = _range.v2;
              }
              widget.onSave(context, _date);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    switch (_date.dateRangeType) {
      case LBDateRange.WEEK:
      case LBDateRange.MONTH:
        return NumberPicker(
          intialValue: _date.dateRangeModifier,
          minValue: 1,
          onChanged: (val) {
            _date.dateRangeModifier = val;
            setState(() {
              _range = _date.getRange();
            });
          },
        );
      case LBDateRange.CUSTOM:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: Text("Start", style: ttLabel(context))),
                  ColoredCell(
                    title: formatDateTime(_range.v1),
                    color: Colors.grey,
                    onTap: () async {
                      var date = await showDatePicker(
                        context: context,
                        initialDate: _range.v1,
                        firstDate: DateTime.parse("2023-01-01"),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _date.rangeStart = date;
                          _range.v1 = date;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text("End", style: ttLabel(context))),
                  ColoredCell(
                    title: formatDateTime(_range.v2),
                    color: Colors.grey,
                    onTap: () async {
                      var date = await showDatePicker(
                        context: context,
                        initialDate: _range.v2,
                        firstDate: _range.v1.add(const Duration(days: 1)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _date.rangeEnd = date;
                          _range.v2 = date;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }
}

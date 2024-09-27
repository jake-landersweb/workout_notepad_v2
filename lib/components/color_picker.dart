import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    this.colors,
    this.initialColor,
    required this.onSave,
    this.rowCount = 8,
  });
  final List<Color>? colors;
  final Color? initialColor;
  final Function(Color? color) onSave;
  final int rowCount;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late List<Color> _colors;
  Color? _selected;

  @override
  void initState() {
    if (widget.colors?.isEmpty ?? true) {
      _colors = _createDefaultColors();
    } else {
      _colors = widget.colors!;
    }
    _selected = widget.initialColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Select Color",
      leading: const [CloseButton2()],
      trailing: [
        Clickable(
          onTap: () {
            widget.onSave(_selected);
            Navigator.of(context).pop();
          },
          child: Text(
            "Save",
            style: ttLabel(
              context,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
      children: [
        const SizedBox(height: 16),
        WrappedButton(
          title: "Clear",
          center: true,
          onTap: () {
            setState(() {
              _selected = null;
            });
          },
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              for (var i = 0; i < _colors.length; i += widget.rowCount)
                _row(context, i, i + widget.rowCount)
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, int startingIndex, int endingIndex) {
    var colors = [];
    for (var i = startingIndex; i < endingIndex; i++) {
      colors.add(
        i >= _colors.length ? Colors.transparent : _colors[i],
      );
    }

    return Row(
      children: [
        for (var i in colors)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Clickable(
                onTap: () {
                  if (i != Colors.transparent) {
                    setState(() {
                      _selected = i;
                    });
                  }
                },
                child: AspectRatio(
                  aspectRatio: 1,
                  child: i == Colors.transparent
                      ? Container()
                      : Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                // shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selected == i ? Colors.white : i,
                                  width: 5,
                                ),
                                color: i,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Color> _createDefaultColors() {
    var baseColors = [
      Colors.purple,
      Colors.pink,
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.yellow,
      Colors.lightGreen,
      Colors.green,
      Colors.teal,
      Colors.lightBlue,
      Colors.blue,
      Colors.blueGrey,
      Colors.grey,
    ];

    List<Color> colors = [];

    for (var color in baseColors) {
      var scheme = getSwatch(color);
      for (var i = 1; i < 9; i++) {
        colors.add(scheme[100 * i]!);
      }
    }

    colors.add(Colors.black);
    var cell = AppColors.cell(context);
    colors.add(cell.shade200);
    colors.add(cell.shade300);
    colors.add(cell.shade400);
    colors.add(cell.shade500);
    colors.add(cell.shade600);
    colors.add(cell.shade700);
    colors.add(cell.shade800);

    return colors;
  }
}

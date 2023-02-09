import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/color.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final List<MaterialColor> _colors = [
    Colors.blue,
    Colors.blueGrey,
    Colors.brown,
    Colors.cyan,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.green,
    Colors.grey,
    Colors.indigo,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.lime,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return sui.AppBar(
      title: "Settings",
      isLarge: true,
      children: [_selectColor(context, dmodel)],
    );
  }

  Widget _selectColor(BuildContext context, DataModel dmodel) {
    return comp.LabeledWidget(
      label: "Color",
      child: sui.DynamicGridView(
        itemCount: _colors.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        builder: (context, index) {
          return _cell(context, dmodel, _colors[index]);
        },
      ),
    );
  }

  Widget _cell(BuildContext context, DataModel dmodel, MaterialColor color) {
    return sui.Button(
      onTap: () => dmodel.setColor(color.toString()),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            height: MediaQuery.of(context).size.width / 5,
            width: MediaQuery.of(context).size.width / 5,
          ),
          if (dmodel.color == color)
            Container(
              height: MediaQuery.of(context).size.width / 6,
              width: MediaQuery.of(context).size.width / 6,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 5),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

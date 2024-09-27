import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_notepad_v2/color_schemes.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_item.dart';
import 'package:workout_notepad_v2/model/getDB.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_builder.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  void initState() {
    super.initState();
    // _test();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Notepad',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) => Scaffold(
            body: _child(context),
          ),
        );
      },
    );
  }

  Widget _child(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.9,
          color: Colors.red,
          child: GraphBuilder(),
        ),
      ],
    );
  }

  void _test() async {
    try {
      print("TESTING");
      var db = await DatabaseProvider().database;

      var lb = LogBuilder();
      lb.items = [
        LogBuilderItem(
          column: LBIColumn.EXERCISE_ID,
          modifier: LBIModifier.EQUALS,
          values: "bcd242fe-207d-493a-9976-f81cdb0ef65f",
        ),
        // LogBuilderItem(
        //   addition: LBIAddition.AND,
        //   table: LBITable.META,
        //   column: "tags",
        //   modifier: LBIModifier.IN,
        //   values: "Working Set",
        // ),
      ];

      lb.grouping = LBGrouping.DATE;
      lb.condensing = LBCondensing.MAX;
      lb.column = LBColumn.WEIGHT;
      lb.weightNormalization = LBWeightNormalization.KG;

      var raw = await lb.queryDB(db);
      var grouped = lb.groupData(raw);
      var graphData = lb.getGraphData(grouped);
      print(graphData);
      print("Evaluated: ${lb.numberOfRecordsEvaluated}");
    } catch (e, stack) {
      print(e);
      print(stack);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_date.dart';
import 'package:workout_notepad_v2/model/getDB.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_bar.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_line.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_panel.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_pie.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_spider.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_table.dart';

class GraphRendererProvider extends ChangeNotifier {
  late LogBuilder logBuilder;
  LogBuilderDate? date;
  bool _isLoading = false;

  List<Tuple2<Object, num>> _data = [];

  GraphRendererProvider({
    required this.logBuilder,
    this.date,
  }) {
    _fetch();
  }

  bool get isLoading => _isLoading;
  List<Tuple2<Object, num>> get data => _data;

  Future<void> _fetch() async {
    _isLoading = true;
    notifyListeners();
    try {
      var db = await DatabaseProvider().database;
      var raw = await logBuilder.queryDB(db, date: date);
      var grouped = logBuilder.groupData(raw);
      var graphData = logBuilder.getGraphData(grouped);
      // print(graphData);
      print("Evaluated: ${logBuilder.numberOfRecordsEvaluated}");

      _data = graphData;
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    _isLoading = false;
    notifyListeners();
  }
}

class GraphRenderer extends StatelessWidget {
  const GraphRenderer({
    super.key,
    required this.logBuilder,
    this.aspectRatio = 1.2,
    this.date,
    this.overrideTitle,
  });
  final LogBuilder logBuilder;
  final double aspectRatio;
  final LogBuilderDate? date;
  final bool? overrideTitle;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GraphRendererProvider(logBuilder: logBuilder, date: date),
      builder: ((context, child) => _build(context)),
    );
  }

  Widget _build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          child: Container(
            decoration: BoxDecoration(
              color: logBuilder.backgroundColor ?? AppColors.cell(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showTitle())
                    Text(logBuilder.graphTitle, style: ttLabel(context)),
                  AspectRatio(
                    aspectRatio: aspectRatio,
                    child: _body(context),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context) {
    var provider = context.watch<GraphRendererProvider>();
    if (provider.isLoading) {
      return const LoadingIndicator();
    }

    if (provider.data.isEmpty) {
      return Center(
        child: Text("No data found.", style: ttcaption(context)),
      );
    }

    return _getGraph(context);
  }

  Widget _getGraph(BuildContext context) {
    // not cached to allow for different graphs with same data
    switch (logBuilder.graphType) {
      case LBGraphType.TIMESERIES:
        return GraphLine(
          logBuilder: logBuilder,
          data: context.read<GraphRendererProvider>().data,
        );
      case LBGraphType.PIE:
        return GraphPie(
          logBuilder: logBuilder,
          data: context.read<GraphRendererProvider>().data,
        );
      case LBGraphType.BAR:
        return GraphBar(
          logBuilder: logBuilder,
          data: context.read<GraphRendererProvider>().data,
        );
      case LBGraphType.SPIDER:
        return GraphSpider(
          logBuilder: logBuilder,
          data: context.read<GraphRendererProvider>().data,
        );
      case LBGraphType.PANEL:
        return GraphPanel(
          logBuilder: logBuilder,
          data: context.read<GraphRendererProvider>().data,
        );
      case LBGraphType.TABLE:
        return GraphTable(
          logBuilder: logBuilder,
          data: context.read<GraphRendererProvider>().data,
        );
    }
  }

  bool _showTitle() {
    if (overrideTitle != null) {
      return overrideTitle!;
    }
    return logBuilder.showTitle;
  }
}

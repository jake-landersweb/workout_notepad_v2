import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_date.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_builder.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_range_picker.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_renderer.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graphs_edit.dart';

class CustomGraphs extends StatefulWidget {
  const CustomGraphs({super.key});

  @override
  State<CustomGraphs> createState() => _CustomGraphsState();
}

class _CustomGraphsState extends State<CustomGraphs> {
  bool _isLoading = false;
  List<LogBuilder> _logBuilders = [];
  List<Key> _keys = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => GraphRangeProvider(
          date: LogBuilderDate(
            dateRangeType: LBDateRange.MONTH,
            dateRangeModifier: 1,
          ),
        ),
        builder: (context, child) => HeaderBar(
          title: "",
          leading: const [BackButton2()],
          trailing: [
            EditButton(onTap: () {
              cupertinoSheet(
                context: context,
                builder: (context) => GraphsEdit(
                  logBuilders: _logBuilders,
                  onSave: ((logBuilders) {
                    _fetch();
                  }),
                ),
              );
            }),
            const SizedBox(width: 16),
            AddButton(onTap: () {
              cupertinoSheet(
                context: context,
                builder: (context) => GraphBuilder(
                  onSaveCallback: ((lb) {
                    _fetch();
                  }),
                ),
              );
            })
          ],
          children: [
            const SizedBox(height: 32),
            _body(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_logBuilders.isEmpty) {
      return Center(
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 2,
              ),
              child: SvgPicture.asset(
                "assets/svg/graph1.svg",
                semanticsLabel: 'Graph1',
              ),
            ),
            Text(
              "You do not have any custom graphs created.",
              textAlign: TextAlign.center,
              style: ttLabel(context),
            ),
            const SizedBox(height: 16),
            WrappedButton(
              title: "Create Custom Graph",
              onTap: () {
                cupertinoSheet(
                  context: context,
                  builder: (context) => GraphBuilder(
                    onSaveCallback: ((lb) async {
                      await _fetch();
                    }),
                  ),
                );
              },
              type: WrappedButtonType.main,
            ),
          ],
        ),
      );
    }

    var range = context.select((GraphRangeProvider value) => value.getDate);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: GraphRangeView(
            date: range,
            onSave: ((_, date) {
              setState(() {
                context.read<GraphRangeProvider>().setDate(date);
                _keys = _generateKeys();
              });
            }),
          ),
        ),
        for (int i = 0; i < _logBuilders.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GraphRenderer(
              key: _keys[i],
              logBuilder: _logBuilders[i],
              date: range,
            ),
          ),
      ],
    );
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var db = await DatabaseProvider().database;
      var rows = await db
          .rawQuery("SELECT * FROM custom_log_builder ORDER BY sortIndex ASC");

      List<LogBuilder> tmp = [];
      for (var i in rows) {
        tmp.add(LogBuilder.fromJson(i));
      }
      setState(() {
        _logBuilders = tmp;
        _keys = _generateKeys();
      });
    } catch (error, stack) {
      NewrelicMobile.instance.recordError(error, stack);
      print(error);
      print(stack);
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<Key> _generateKeys() {
    const uuid = Uuid();
    List<Key> tmp = [];
    for (int i = 0; i < _logBuilders.length; i++) {
      tmp.add(ValueKey(uuid.v4()));
    }
    return tmp;
  }
}

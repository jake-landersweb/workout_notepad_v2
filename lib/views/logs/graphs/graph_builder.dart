// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/color_picker.dart';
import 'package:workout_notepad_v2/components/colored_cell.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_item.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_item_builder.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_item_cell.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_range_picker.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_renderer.dart';
import 'package:workout_notepad_v2/views/profile/paywall.dart';
import 'package:workout_notepad_v2/views/profile/subscriptions.dart';

class GraphBuilder extends StatefulWidget {
  const GraphBuilder({
    super.key,
    this.lb,
    this.onSaveCallback,
  });
  final LogBuilder? lb;
  // optionally hook into the action after the data was posted to the database
  final void Function(LogBuilder lb)? onSaveCallback;

  @override
  State<GraphBuilder> createState() => _GraphBuilderState();
}

class _GraphBuilderState extends State<GraphBuilder> {
  late LogBuilder _lb;
  late ValueKey _graphKey;
  late TextEditingController _textController;

  @override
  void initState() {
    _lb = widget.lb ??
        LogBuilder(
          items: [
            LogBuilderItem(
              addition: LBIAddition.AND,
              column: LBIColumn.TAGS,
              modifier: LBIModifier.CONTAINS,
              values: "Working Set",
            )
          ],
        );
    _graphKey = ValueKey(const Uuid().v4());
    _textController =
        TextEditingController(text: widget.lb?.title ?? _lb.generateTitle());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  Widget _body(BuildContext context) {
    DataModel dmodel = context.read();
    return HeaderBar.sheet(
      title: "Graph Builder",
      horizontalSpacing: 0,
      leading: const [CloseButton2(useRoot: true)],
      trailing: [
        Clickable(
          onTap: () async {
            if (dmodel.hasValidSubscription()) {
              if (await _save(context)) {
                if (widget.onSaveCallback != null) {
                  widget.onSaveCallback!(_lb);
                }
                Navigator.of(context).pop();
              }
            } else {
              showPaywall(context);
            }
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Section(
            "Visualization",
            allowsCollapse: true,
            initOpen: true,
            child: Column(
              children: [
                GraphRangeView(
                  date: _lb.date,
                  onSave: ((context, date) {
                    setState(() {
                      _lb.date = date;
                    });
                  }),
                ),
                const SizedBox(height: 4),
                _graphTypes(context),
                const SizedBox(height: 4),
                GraphRenderer(
                  overrideTitle: false,
                  key: _graphKey,
                  logBuilder: _lb,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WrappedButton(
                        title: "Reload",
                        // isLoading: _isLoading,
                        type: WrappedButtonType.main,
                        rowAxisSize: MainAxisSize.max,
                        center: true,
                        onTap: () async {
                          setState(() {
                            _graphKey = ValueKey(const Uuid().v4());
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _params(context),
        ),
        _conditions(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _settings(context),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _graphTypes(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          for (var i in LBGraphType.values)
            Expanded(
              child: Clickable(
                onTap: () {
                  if (_lb.grouping.getValidGraphTypes().contains(i)) {
                    setState(() {
                      _lb.graphType = i;
                      _graphKey = ValueKey(const Uuid().v4());
                    });
                  }
                },
                child: Opacity(
                  opacity:
                      _lb.grouping.getValidGraphTypes().contains(i) ? 1 : 0.5,
                  child: Container(
                    color: _lb.graphType == i
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.cell(context),
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Icon(
                          i.getIcon(),
                          color: _lb.graphType == i
                              ? AppColors.cell(context)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _conditions(BuildContext context) {
    return Section(
      "Conditions",
      allowsCollapse: true,
      initOpen: true,
      headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Column(
        children: [
          ColoredCell(
            title: "WHERE",
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            size: ColoredCellSize.small,
          ),
          RawReorderableList(
            items: _lb.items,
            areItemsTheSame: (p0, p1) => p0.id == p1.id,
            header: const SizedBox(height: 0),
            footer: const SizedBox(height: 0),
            onReorderFinished: (item, from, to, newItems) {
              setState(() {
                _lb.items = newItems;
              });
            },
            slideBuilder: (item, index) {
              return ActionPane(
                extentRatio: 0.3,
                motion: const DrawerMotion(),
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          SlidableAction(
                            borderRadius: BorderRadius.circular(10),
                            onPressed: (context) async {
                              await Future.delayed(
                                const Duration(milliseconds: 100),
                              );
                              setState(() {
                                _lb.items.removeAt(index);
                              });
                            },
                            icon: LineIcons.alternateTrash,
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.error(),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            builder: (item, index, handle, inDrag) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Clickable(
                      onTap: () {
                        cupertinoSheet(
                          context: context,
                          builder: (context) {
                            return GraphItemBuilder(
                              item: item,
                              onSave: (context, item) {
                                setState(() {
                                  _lb.items[index] = item;
                                });
                              },
                            );
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: inDrag
                              ? AppColors.cell(context)[50]
                              : AppColors.cell(context),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: GraphItemCell(
                                        index: index, item: item)),
                                const SizedBox(width: 4),
                                handle,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: WrappedButton(
              title: "Add New",
              type: WrappedButtonType.standard,
              center: true,
              onTap: () {
                cupertinoSheet(
                  context: context,
                  builder: (context) => GraphItemBuilder(
                    onSave: (context, item) {
                      setState(() {
                        _lb.items.add(item);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _params(BuildContext context) {
    return Section(
      "Params",
      allowsCollapse: true,
      initOpen: true,
      child: Column(
        children: [
          _paramCell(context, "Group By", _lb.grouping.name, (context) {
            showFloatingSheet(
              context: context,
              builder: (context) => SheetSelector(
                title: "Select Grouping",
                items: LBGrouping.values,
                titleBuilder: (context, item) {
                  return item.name;
                },
                initialItem: _lb.grouping,
                onSelect: ((context, index, item) {
                  var newValidGraphTypes = item.getValidGraphTypes();
                  if (!newValidGraphTypes.contains(_lb.graphType)) {
                    _lb.graphType = newValidGraphTypes[0];
                    _graphKey = ValueKey(const Uuid().v4());
                  }
                  setState(() {
                    _lb.grouping = item;
                  });
                }),
              ),
            );
          }),
          _paramCell(
            context,
            "Condensing Method",
            _lb.condensing.name,
            (context) => showFloatingSheet(
              context: context,
              builder: (context) => SheetSelector(
                title: "Condensing Method",
                items: LBCondensing.values,
                titleBuilder: (context, item) {
                  return item.name;
                },
                initialItem: _lb.condensing,
                onSelect: ((context, index, item) {
                  setState(() {
                    _lb.condensing = item;
                  });
                }),
              ),
            ),
          ),
          _paramCell(
            context,
            "Metric",
            _lb.column.name,
            (context) => showFloatingSheet(
              context: context,
              builder: (context) => SheetSelector(
                title: "Select Metric",
                items: LBColumn.values,
                titleBuilder: (context, item) {
                  return item.name;
                },
                initialItem: _lb.column,
                onSelect: ((context, index, item) {
                  setState(() {
                    _lb.column = item;
                  });
                }),
              ),
            ),
          ),
          _paramCell(
            context,
            "lbs/kg",
            _lb.weightNormalization.name,
            (context) => showFloatingSheet(
              context: context,
              builder: (context) => SheetSelector(
                title: "lbs/kg",
                items: LBWeightNormalization.values,
                titleBuilder: (context, item) {
                  return item.name;
                },
                initialItem: _lb.weightNormalization,
                onSelect: ((context, index, item) {
                  setState(() {
                    _lb.weightNormalization = item;
                  });
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paramCell(
    BuildContext context,
    String title,
    String value,
    Function(BuildContext context) onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(title, style: ttLabel(context)),
          Clickable(
            onTap: () => onTap(context),
            child: ColoredCell(title: value, on: false),
          ),
        ],
      ),
    );
  }

  Widget _settings(BuildContext context) {
    return Section(
      "Customization",
      allowsCollapse: true,
      initOpen: true,
      child: Column(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cell(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Field(
                    controller: _textController,
                    labelText: "Title",
                    charLimit: 80,
                    maxLines: 5,
                    showCharacters: true,
                    onChanged: (val) {},
                  ),
                ),
              ),
              const SizedBox(height: 4),
              WrappedButton(
                title: "Generate",
                center: true,
                height: 30,
                backgroundColor: AppColors.divider(context),
                onTap: () {
                  var gen = _lb.generateTitle();
                  if (gen.length > 80) {
                    gen = gen.substring(0, 80);
                  }
                  setState(() {
                    _textController.text = gen;
                  });
                },
              ),
            ],
          ),
          _settingsCell(context, "Show Legend", _lb.showLegend, (val) {
            setState(() {
              _lb.showLegend = val;
            });
          }),
          _settingsCell(context, "Show X-Axis", _lb.showXAxis, (val) {
            setState(() {
              _lb.showXAxis = val;
            });
          }),
          _settingsCell(context, "Show Y-Axis", _lb.showYAxis, (val) {
            setState(() {
              _lb.showYAxis = val;
            });
          }),
          _settingsCell(context, "Show Title", _lb.showTitle, (val) {
            setState(() {
              _lb.showTitle = val;
            });
          }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("Background Color", style: ttLabel(context)),
                Clickable(
                  onTap: () {
                    cupertinoSheet(
                      context: context,
                      builder: (context) {
                        return ColorPicker(
                          initialColor: _lb.backgroundColor,
                          onSave: (color) {
                            setState(() {
                              _lb.backgroundColor = color;
                            });
                          },
                        );
                      },
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_lb.backgroundColor == null)
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.red.shade400,
                                ],
                              )),
                          height: 40,
                          width: 40,
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: _lb.backgroundColor!,
                            shape: BoxShape.circle,
                          ),
                          height: 40,
                          width: 40,
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cell(context),
                          shape: BoxShape.circle,
                        ),
                        height: 22,
                        width: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("Color", style: ttLabel(context)),
                Clickable(
                  onTap: () {
                    cupertinoSheet(
                      context: context,
                      builder: (context) {
                        return ColorPicker(
                          initialColor: _lb.color,
                          onSave: (color) {
                            setState(() {
                              _lb.color = color;
                            });
                          },
                        );
                      },
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_lb.color == null)
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.red.shade400,
                                ],
                              )),
                          height: 40,
                          width: 40,
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: _lb.color!,
                            shape: BoxShape.circle,
                          ),
                          height: 40,
                          width: 40,
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cell(context),
                          shape: BoxShape.circle,
                        ),
                        height: 22,
                        width: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCell(
    BuildContext context,
    String title,
    bool value,
    Function(bool val) onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(title, style: ttLabel(context)),
          Switch(
            value: value,
            onChanged: onTap,
          ),
        ],
      ),
    );
  }

  Future<bool> _save(BuildContext context) async {
    try {
      _lb.title = _textController.text;
      var db = await DatabaseProvider().database;
      await db.insert("custom_log_builder", _lb.toPayload());
      snackbarStatus(context, "Successfully saved graph");
      return true;
    } catch (error, stack) {
      logger.exception(error, stack);
      snackbarErr(context, "There was an issue saving the graph: $error");
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';

class InteractiveSheet extends StatefulWidget {
  const InteractiveSheet({
    super.key,
    required this.header,
    required this.builder,
  });
  final Widget Function(BuildContext context) header;
  final Widget Function(BuildContext context) builder;

  @override
  State<InteractiveSheet> createState() => _InteractiveSheetState();
}

class _InteractiveSheetState extends State<InteractiveSheet> {
  double _offsetY = -6;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _offsetY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      height: double.infinity,
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: widget.builder(context),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return AnimatedSlide(
      offset: Offset(0, _offsetY),
      duration: const Duration(milliseconds: 500),
      curve: Sprung(36),
      child: Container(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: widget.header(context),
          ),
        ),
      ),
    );
  }
}

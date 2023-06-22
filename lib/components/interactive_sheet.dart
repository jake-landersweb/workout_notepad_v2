import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

import 'package:workout_notepad_v2/model/root.dart';

class InteractiveSheet extends StatefulWidget {
  const InteractiveSheet({
    super.key,
    required this.header,
    required this.builder,
    this.headerPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });
  final Widget Function(BuildContext context) header;
  final Widget Function(BuildContext context) builder;
  final EdgeInsets headerPadding;

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

  @override
  void dispose() {
    super.dispose();
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
    return AnimatedSlide(
      offset: Offset(0, _offsetY),
      duration: const Duration(milliseconds: 500),
      curve: Sprung(36),
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: widget.headerPadding,
            child: widget.header(context),
          ),
        ),
      ),
    );
  }
}

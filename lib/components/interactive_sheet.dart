import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';

import 'package:workout_notepad_v2/utils/root.dart';

class InteractiveSheet extends StatefulWidget {
  const InteractiveSheet({
    super.key,
    required this.header,
    required this.builder,
    this.headerPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    this.headerColor,
  });
  final Widget Function(BuildContext context) header;
  final Widget Function(BuildContext context) builder;
  final EdgeInsets headerPadding;
  final Color? headerColor;

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
      color: AppColors.background(context),
      height: double.infinity,
      child: Column(
        children: [
          _header(context),
          Divider(
            color: AppColors.border(context),
          ),
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
        color: widget.headerColor ??
            Theme.of(context).colorScheme.primary.withOpacity(0.15),
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

import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/clickable.dart';

import 'root.dart' as cv;

class Section extends StatefulWidget {
  const Section(
    this.title, {
    Key? key,
    required this.child,
    this.allowsCollapse = false,
    this.initOpen = false,
    this.headerPadding = const EdgeInsets.fromLTRB(16, 8, 0, 4),
    this.color = Colors.blue,
    this.animateOpen = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final Widget child;
  final bool? allowsCollapse;
  final bool? initOpen;
  final EdgeInsets headerPadding;
  final Color color;
  final bool animateOpen;
  final Color? textColor;

  @override
  _SectionState createState() => _SectionState();
}

class _SectionState extends State<Section> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    if (widget.allowsCollapse ?? false) {
      _controller = AnimationController(
          duration: const Duration(milliseconds: 550),
          vsync: this,
          value: (widget.initOpen ?? false)
              ? 1
              : widget.animateOpen
                  ? 0
                  : 1);
      _animation = CurvedAnimation(
        parent: _controller,
        curve: Sprung.overDamped,
      );
      // open container if is expanded
      if ((widget.initOpen ?? false) && widget.animateOpen) {
        _controller.forward();
      }
      _isOpen = widget.initOpen ?? false;
    }
  }

  _toggleContainer() {
    if (_animation.status != AnimationStatus.completed) {
      _controller.forward();
      setState(() {
        _isOpen = true;
      });
    } else {
      _controller.animateBack(0,
          duration: const Duration(milliseconds: 550),
          curve: Sprung.overDamped);
      setState(() {
        _isOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allowsCollapse ?? false) {
      return Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.2),
          dividerTheme: const DividerThemeData(
            thickness: 0.5,
            indent: 16,
            endIndent: 0,
          ),
        ),
        child: _collapseableSection(context),
      );
    } else {
      return _defaultSection(context);
    }
  }

  Widget _defaultSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: widget.headerPadding,
          child: Row(
            children: [
              Expanded(child: _title(context)),
              Row(
                children: [
                  // so this and collapsable section are the same height above view
                  Opacity(
                    opacity: 0,
                    child: Icon(
                      Icons.chevron_left,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        widget.child,
      ],
    );
  }

  Widget _collapseableSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: widget.headerPadding,
              child: _title(context),
            ),
            Expanded(
              child: Divider(
                  height: 0.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            Padding(
              padding: widget.headerPadding,
              child: Row(
                children: [
                  Clickable(
                    onTap: () {
                      _toggleContainer();
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 550),
                        curve: Sprung.overDamped,
                        turns: _isOpen ? 0.25 : -0.25,
                        child: Icon(Icons.chevron_left,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizeTransition(
          sizeFactor: _animation,
          axis: Axis.vertical,
          child: AnimatedOpacity(
            opacity: _isOpen ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: widget.child,
          ),
        ),
      ],
    );
  }

  Widget _title(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Text(
        widget.title.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.w500, color: widget.textColor),
      ),
    );
  }
}

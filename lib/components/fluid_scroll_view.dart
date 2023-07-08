import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'dart:math' as math;

class FluidScrollView extends StatefulWidget {
  const FluidScrollView({
    super.key,
    required this.children,
    this.spacing = 16,
    this.factor,
    this.controller,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });
  final List<Widget> children;
  final double spacing;
  final double? factor;
  final ScrollController? controller;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  State<FluidScrollView> createState() => _FluidScrollViewState();
}

class _FluidScrollViewState extends State<FluidScrollView> {
  double _scrollVelocity = 0;
  double _fingerPosition = 0;
  double _scrollPosition = 0;
  bool _isTouchingScreen = false;
  late ScrollController _controller;
  int _lastMilli = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    if (widget.controller == null) {
      _controller = ScrollController();
    } else {
      _controller = widget.controller!;
    }
    _controller.addListener(() {
      _scrollPosition = _controller.offset;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) {
        // get position of finger on screen when moving
        setState(() {
          _isTouchingScreen = true;
          _fingerPosition = event.position.dy;
        });
      },
      onPointerUp: (event) {
        setState(() {
          _isTouchingScreen = false;
        });
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final now = DateTime.now();
          final timeDiff = now.millisecondsSinceEpoch - _lastMilli;
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.axis == Axis.horizontal) {
              return true;
            }
            // if (!_isTouchingScreen) {
            //   setState(() {
            //     _fingerPosition += notification.scrollDelta ?? 0;
            //   });
            // }
            final pixelsPerMilli = notification.scrollDelta ?? 0 / timeDiff;
            setState(() {
              _scrollVelocity = pixelsPerMilli;
            });
            _lastMilli = DateTime.now().millisecondsSinceEpoch;
          }

          if (notification is ScrollEndNotification) {
            setState(() {
              _scrollVelocity = 0;
            });
            _lastMilli = DateTime.now().millisecondsSinceEpoch;
          } else {
            return true;
          }

          return true;
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics()
              .applyTo(const BouncingScrollPhysics()),
          controller: _controller,
          itemCount: widget.children.length,
          itemBuilder: (context, index) {
            return _ScrollCell(
              index: index,
              spacing: widget.spacing,
              fingerLocation: _fingerPosition,
              scrollVelocity: _scrollVelocity,
              factor: widget.factor,
              child: widget.children[index],
            );
          },
        ),
      ),
    );
  }
}

class _ScrollCell extends StatefulWidget {
  const _ScrollCell({
    required this.index,
    required this.child,
    required this.spacing,
    required this.fingerLocation,
    required this.scrollVelocity,
    this.factor,
  });
  final int index;
  final Widget child;
  final double spacing;
  final double fingerLocation;
  final double scrollVelocity;
  final double? factor;

  @override
  State<_ScrollCell> createState() => __ScrollCellState();
}

class __ScrollCellState extends State<_ScrollCell> {
  final GlobalKey _key = GlobalKey();
  double? _size;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing),
      child: AnimatedSlide(
        key: _key,
        offset: Offset(0, _getYOffset()),
        duration: const Duration(milliseconds: 400),
        curve: Sprung(50),
        child: widget.child,
      ),
    );
  }

  double _getPosition() {
    if (_key.currentContext == null) {
      return 0;
    }
    RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
    try {
      Offset position = box.localToGlobal(Offset.zero);
      double y = position.dy;
      _size = box.size.height;
      return y;
    } catch (_) {
      // ignore for layout problems
      return 0;
    }
  }

  double _getYOffset() {
    double globalPosition = _getPosition();
    if (globalPosition == 0) {
      return 0;
    }
    if (widget.fingerLocation == 0) {
      return 0;
    }
    double val = ((widget.fingerLocation - globalPosition) / 1000) *
        (widget.scrollVelocity / (widget.factor ?? ((_size ?? 10) / 5)));
    double out = math.min(1, math.max(-1, val));
    if (globalPosition > widget.fingerLocation) {
      out = -out;
    }
    return out;
  }
}

// for calculating the velocity of a scrollable widget
class _ScrollVelocityListener extends StatefulWidget {
  final Function(double) onVelocity;
  final Widget child;

  const _ScrollVelocityListener({
    required this.onVelocity,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _ScrollVelocityListenerState();
}

class _ScrollVelocityListenerState extends State<_ScrollVelocityListener> {
  int lastMilli = DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final now = DateTime.now();
        final timeDiff = now.millisecondsSinceEpoch - lastMilli;
        if (notification is ScrollUpdateNotification) {
          final pixelsPerMilli = notification.scrollDelta ?? 0 / timeDiff;
          widget.onVelocity(
            pixelsPerMilli,
          );
          lastMilli = DateTime.now().millisecondsSinceEpoch;
        }

        if (notification is ScrollEndNotification) {
          widget.onVelocity(0);
          lastMilli = DateTime.now().millisecondsSinceEpoch;
        } else {
          return true;
        }
        return true;
      },
      child: widget.child,
    );
  }
}

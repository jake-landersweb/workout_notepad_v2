import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// Used for wrapping a child in a very basic hit detection
/// widget. This widget will change the opacity of the widget to
/// be [tappedOpacity] when pressed. Can optionally specify the
/// speed of the transition with [duration].
class Clickable extends StatefulWidget {
  const Clickable({
    super.key,
    required this.onTap,
    required this.child,
    this.duration = const Duration(milliseconds: 50),
    this.tappedOpacity = 0.4,
    this.showTap = true,
  });

  final VoidCallback onTap;
  final Widget child;
  final Duration duration;
  final double tappedOpacity;
  final bool showTap;

  @override
  State<Clickable> createState() => _ClickableState();
}

class _ClickableState extends State<Clickable> {
  bool _isPressed = false;
  DateTime pressedTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    if (widget.showTap) {
      return GestureDetector(
        onTap: () => widget.onTap(),
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        onTapDown: (details) {
          setState(() {
            _isPressed = true;
          });
          pressedTime = DateTime.now();
        },
        onTapUp: ((details) async {
          var now = DateTime.now();
          if (now.difference(pressedTime).inMilliseconds < 50) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          setState(() {
            _isPressed = false;
          });
        }),
        child: AnimatedOpacity(
          opacity: _isPressed ? widget.tappedOpacity : 1,
          duration: widget.duration,
          child: widget.child,
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => widget.onTap(),
        child: widget.child,
      );
    }
  }
}

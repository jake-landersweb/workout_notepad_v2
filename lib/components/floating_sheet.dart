import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/root.dart';

/// Shows a floating sheet with padding based on the platform
class _FloatingSheet extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const _FloatingSheet({
    Key? key,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Sprung(36),
      padding: EdgeInsets.only(
        bottom: (MediaQuery.of(context).viewInsets.bottom -
                    MediaQuery.of(context).viewPadding.bottom) <
                0
            ? 0
            : (MediaQuery.of(context).viewInsets.bottom - bottomPadding),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, bottomPadding + 10),
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: child,
        ),
      ),
    );
  }
}

/// Presents a floating model.
Future<T> showFloatingSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  bool useRootNavigator = false,
  Curve? curve,
  bool? isDismissable,
  bool enableDrag = true,
  double childSpace = 8,
}) async {
  final result = await showCustomModalBottomSheet(
    isDismissible: isDismissable ?? true,
    context: context,
    builder: builder,
    enableDrag: enableDrag,
    animationCurve: curve ?? Sprung(36),
    duration: const Duration(milliseconds: 500),
    containerWidget: (_, animation, child) => _FloatingSheet(
      backgroundColor: backgroundColor,
      child: child,
    ),
    expand: false,
    useRootNavigator: useRootNavigator,
  );

  return result;
}

class FloatingSheet extends StatefulWidget {
  const FloatingSheet({
    Key? key,
    required this.title,
    required this.child,
    this.headerHeight = 50,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
    this.icon,
    this.useRoot = false,
    this.childSpace = 8,
  }) : super(key: key);

  final String title;
  final Widget child;
  final double headerHeight;
  final EdgeInsets padding;
  final IconData? icon;
  final bool useRoot;
  final double childSpace;

  @override
  State<FloatingSheet> createState() => _FloatingSheetState();
}

class _FloatingSheetState extends State<FloatingSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: widget.padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Clickable(
                      onTap: () =>
                          Navigator.of(context, rootNavigator: widget.useRoot)
                              .pop(),
                      child: Icon(
                        widget.icon ?? Icons.close,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.childSpace),
                widget.child,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

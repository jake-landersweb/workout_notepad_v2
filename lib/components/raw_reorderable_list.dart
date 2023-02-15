import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

class RawReorderableList<T extends Object> extends StatefulWidget {
  const RawReorderableList({
    super.key,
    required this.items,
    required this.areItemsTheSame,
    required this.onReorderFinished,
    this.slideBuilder,
    required this.builder,
    this.shrinkWrap = true,
    this.padding,
    this.header,
    this.footer,
  });
  final List<T> items;
  final bool Function(T item1, T item2) areItemsTheSame;
  final void Function(T item, int from, int to, List<T> newItems)
      onReorderFinished;
  final ActionPane? Function(T item, int index)? slideBuilder;
  final Widget Function(T item, int index, Handle handle, bool inDrag) builder;
  final bool shrinkWrap;
  final EdgeInsets? padding;
  final Widget? header;
  final Widget? footer;

  @override
  State<RawReorderableList<T>> createState() => _RawReorderableListState<T>();
}

class _RawReorderableListState<T extends Object>
    extends State<RawReorderableList<T>> {
  @override
  Widget build(BuildContext context) {
    return ImplicitlyAnimatedReorderableList<T>(
      items: widget.items,
      padding: widget.padding,
      areItemsTheSame: widget.areItemsTheSame,
      removeDuration: const Duration(milliseconds: 500),
      liftDuration: const Duration(milliseconds: 500),
      insertDuration: const Duration(milliseconds: 500),
      settleDuration: const Duration(milliseconds: 300),
      updateDuration: const Duration(milliseconds: 300),
      reorderDuration: const Duration(milliseconds: 300),
      onReorderFinished: widget.onReorderFinished,
      header: widget.header,
      footer: widget.footer,
      itemBuilder: (context, itemAnimation, item, index) {
        // Each item must be wrapped in a Reorderable widget.
        return Reorderable(
          // Each item must have an unique key.
          key: ValueKey(item),
          // The animation of the Reorderable builder can be used to
          // change to appearance of the item between dragged and normal
          // state. For example to add elevation when the item is being dragged.
          // This is not to be confused with the animation of the itemBuilder.
          // Implicit animations (like AnimatedContainer) are sadly not yet supported.
          builder: (context, dragAnimation, inDrag) {
            return SizeFadeTransition(
              sizeFraction: 0.5,
              curve: Curves.easeInOut,
              animation: itemAnimation,
              child: Slidable(
                key: ValueKey(index),
                endActionPane: widget.slideBuilder == null
                    ? null
                    : widget.slideBuilder!(item, index),
                child: widget.builder(
                  item,
                  index,
                  const Handle(
                    delay: Duration.zero,
                    child: Icon(
                      LineIcons.bars,
                      color: Colors.grey,
                    ),
                  ),
                  inDrag,
                ),
              ),
            );
          },
        );
      },
      shrinkWrap: widget.shrinkWrap,
    );
  }
}

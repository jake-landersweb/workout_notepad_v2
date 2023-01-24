import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

class ReorderableList<T extends Object> extends StatefulWidget {
  const ReorderableList({
    super.key,
    required this.items,
    required this.areItemsTheSame,
    required this.onReorderFinished,
    this.slideBuilder,
    required this.builder,
    this.shrinkWrap = true,
    this.horizontalSpacing = 16,
    this.borderRadius = 10,
  });
  final List<T> items;
  final bool Function(T item1, T item2) areItemsTheSame;
  final void Function(T item, int from, int to, List<T> newItems)
      onReorderFinished;
  final ActionPane? Function(T item, int index)? slideBuilder;
  final Widget Function(T item, int index) builder;
  final bool shrinkWrap;
  final double horizontalSpacing;
  final double borderRadius;

  @override
  State<ReorderableList<T>> createState() => _ReorderableListState<T>();
}

class _ReorderableListState<T extends Object>
    extends State<ReorderableList<T>> {
  @override
  Widget build(BuildContext context) {
    return ImplicitlyAnimatedReorderableList<T>(
      items: widget.items,
      areItemsTheSame: widget.areItemsTheSame,
      removeDuration: const Duration(milliseconds: 500),
      liftDuration: const Duration(milliseconds: 500),
      insertDuration: const Duration(milliseconds: 500),
      settleDuration: const Duration(milliseconds: 300),
      updateDuration: const Duration(milliseconds: 300),
      reorderDuration: const Duration(milliseconds: 300),
      onReorderFinished: widget.onReorderFinished,
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
            return Padding(
              padding: EdgeInsets.only(right: widget.horizontalSpacing),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: index == 0
                      ? Radius.circular(widget.borderRadius)
                      : Radius.zero,
                  bottomRight: index == widget.items.length - 1
                      ? Radius.circular(widget.borderRadius)
                      : Radius.zero,
                ),
                child: SizeFadeTransition(
                  sizeFraction: 0.5,
                  curve: Curves.easeInOut,
                  animation: itemAnimation,
                  child: Slidable(
                    key: ValueKey(index),
                    endActionPane: widget.slideBuilder == null
                        ? null
                        : widget.slideBuilder!(item, index),
                    child: Padding(
                      padding: EdgeInsets.only(left: widget.horizontalSpacing),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: inDrag ? Colors.grey[100] : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: index == 0
                                    ? Radius.circular(widget.borderRadius)
                                    : Radius.zero,
                                bottomLeft: index == widget.items.length - 1
                                    ? Radius.circular(widget.borderRadius)
                                    : Radius.zero,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: widget.builder(item, index)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Handle(
                                    delay: Duration.zero,
                                    child: Icon(
                                      LineIcons.bars,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (index < widget.items.length)
                            Divider(
                              height: 0.5,
                              color: sui.CustomColors.textColor(context)
                                  .withOpacity(0.1),
                              indent: 16,
                              endIndent: 0,
                            ),
                        ],
                      ),
                    ),
                  ),
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

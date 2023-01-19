import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  late List<int> items;

  @override
  void initState() {
    items = List<int>.generate(100, (index) => index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ImplicitlyAnimatedReorderableList<int>(
      items: items,
      areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
      removeDuration: const Duration(milliseconds: 500),
      liftDuration: const Duration(milliseconds: 500),
      insertDuration: const Duration(milliseconds: 500),
      settleDuration: const Duration(milliseconds: 300),
      updateDuration: const Duration(milliseconds: 300),
      reorderDuration: const Duration(milliseconds: 300),
      onReorderFinished: (item, from, to, newItems) {
        // Remember to update the underlying data when the list has been
        // reordered.
        setState(() {
          items
            ..clear()
            ..addAll(newItems);
        });
      },
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
              sizeFraction: 0.7,
              curve: Curves.easeInOut,
              animation: itemAnimation,
              child: Slidable(
                key: ValueKey(index),
                endActionPane: ActionPane(
                  extentRatio: 0.25,
                  motion: const BehindMotion(),
                  children: [
                    Expanded(
                      child: ClipRRect(
                        // borderRadius: BorderRadius.vertical(
                        //   top: Radius.circular(
                        //     widget.isFirst ? widget.borderRadius : 0,
                        //   ),
                        //   bottom: Radius.circular(
                        //     widget.isLast ? widget.borderRadius : 0,
                        //   ),
                        // ),
                        child: Row(children: [
                          SlidableAction(
                            onPressed: (context) async {
                              await Future.delayed(
                                  const Duration(milliseconds: 100));
                              setState(() {
                                items.removeAt(index);
                              });
                            },
                            icon: Icons.delete,
                            foregroundColor: Colors.red,
                            backgroundColor: Colors.red[100]!,
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: inDrag ? Colors.grey[100] : Colors.white,
                  child: ListTile(
                    title: Text(item.toString()),
                    // The child of a Handle can initialize a drag/reorder.
                    // This could for example be an Icon or the whole item itself. You can
                    // use the delay parameter to specify the duration for how long a pointer
                    // must press the child, until it can be dragged.
                    trailing: const Handle(
                      delay: Duration(milliseconds: 100),
                      child: Icon(
                        Icons.list,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      // Since version 0.2.0 you can also display a widget
      // before the reorderable items...
      header: Container(
        height: 200,
        color: Colors.red,
      ),
      // ...and after. Note that this feature - as the list itself - is still in beta!
      footer: Container(
        height: 200,
        color: Colors.green,
      ),
      // If you want to use headers or footers, you should set shrinkWrap to true
      shrinkWrap: true,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class TabBarItem {
  late IconData child;
  late String title;

  TabBarItem({
    required this.child,
    required this.title,
  });
}

class TabBar extends StatefulWidget {
  const TabBar({
    super.key,
    required this.index,
    required this.items,
    this.showTitles = false,
    required this.builder,
    required this.onItemTap,
  });
  final int index;
  final List<TabBarItem> items;
  final bool showTitles;
  final Widget Function(BuildContext context, int index, TabBarItem item)
      builder;
  final Function(BuildContext context, int index, TabBarItem item) onItemTap;

  @override
  State<TabBar> createState() => _TabBarState();
}

class _TabBarState extends State<TabBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 0.5,
          indent: 0,
          endIndent: 0,
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
        ),
        BlurredContainer(
          width: double.infinity,
          borderRadius: BorderRadius.circular(0),
          backgroundColor: AppColors.background(context),
          opacity: 0.8,
          blur: 12,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: Padding(
              padding: _barPadding(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int i = 0; i < widget.items.length; i++)
                    Clickable(
                      onTap: () {
                        widget.onItemTap(context, i, widget.items[i]);
                      },
                      child: widget.builder(context, i, widget.items[i]),
                    )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  EdgeInsets _barPadding(BuildContext context) {
    if (MediaQuery.of(context).viewPadding.bottom == 0) {
      return const EdgeInsets.only(top: 8, bottom: 16);
    } else {
      return const EdgeInsets.only(top: 8);
    }
  }
}

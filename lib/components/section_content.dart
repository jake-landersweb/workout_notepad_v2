import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/contained_list.dart';
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'dart:math' as math;

enum StyledSectionItemPost { none, view, model, external }

class StyledSectionItem {
  final String title;
  final IconData icon;
  final Color color;
  final AsyncCallback onTap;
  final StyledSectionItemPost post;
  final bool isLocked;

  StyledSectionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.post,
    required this.isLocked,
  });

  Widget getPostContent(BuildContext context) {
    if (isLocked) {
      return Icon(
        Icons.lock_rounded,
        color: AppColors.subtext(context),
      );
    }
    switch (post) {
      case StyledSectionItemPost.none:
        return Container();
      case StyledSectionItemPost.view:
        return Icon(
          Icons.chevron_right_rounded,
          color: AppColors.subtext(context),
        );
      case StyledSectionItemPost.model:
        return Transform.rotate(
          angle: math.pi / -2,
          child: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.subtext(context),
          ),
        );
      case StyledSectionItemPost.external:
        return Icon(
          Icons.open_in_new_rounded,
          color: AppColors.subtext(context),
        );
    }
  }
}

class StyledSection extends StatefulWidget {
  const StyledSection({
    super.key,
    required this.title,
    required this.items,
  });
  final String title;
  final List<StyledSectionItem> items;

  @override
  State<StyledSection> createState() => _StyledSectionState();
}

class _StyledSectionState extends State<StyledSection> {
  int _loadingIndex = -1;

  @override
  Widget build(BuildContext context) {
    return ContainedList<StyledSectionItem>(
      leadingPadding: 0,
      trailingPadding: 0,
      childPadding: EdgeInsets.zero,
      children: widget.items,
      onChildTap: (context, item, index) async {
        setState(() {
          _loadingIndex = index;
        });
        await item.onTap();
        setState(() {
          _loadingIndex = -1;
        });
      },
      childBuilder: (context, item, index) {
        return Row(
          children: [
            Expanded(
              child: WrappedButton(
                title: item.title,
                icon: item.icon,
                iconBg: item.color,
                isLoading: _loadingIndex == index,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: item.getPostContent(context),
            ),
          ],
        );
      },
    );
  }
}

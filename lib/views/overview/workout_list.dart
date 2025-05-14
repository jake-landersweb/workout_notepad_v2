import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/section.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/views/workouts/workout_cell.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({
    super.key,
    required this.title,
    required this.workouts,
    this.allowsExpand = true,
  });
  final String title;
  final List<Workout> workouts;
  final bool allowsExpand;

  @override
  State<WorkoutList> createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  @override
  Widget build(BuildContext context) {
    var localTemplates = context.select(
      (DataModel value) => value.workoutTemplates,
    );

    return Column(
      children: [
        Section(
          widget.title,
          allowsCollapse: false,
          initOpen: true,
          headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: widget.allowsExpand
                ? ExpandableAnimatedList(
                    data: widget.workouts,
                    allowsExpand: widget.allowsExpand,
                    itemBuilder: (context, i) =>
                        _builder(context, i, localTemplates),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.border(context), width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.workouts.length,
                        itemBuilder: (context, i) =>
                            _builder(context, i, localTemplates),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _builder(
      BuildContext context, int i, List<WorkoutTemplate> localTemplates) {
    return Column(
      children: [
        Clickable(
          onTap: () {},
          child: _workoutCell(
            context,
            widget.workouts[i],
            localTemplates,
          ),
        ),
        if (i < widget.workouts.length - 1)
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.divider(context),
          ),
      ],
    );
  }

  Widget _workoutCell(
    BuildContext context,
    Workout template,
    List<Workout> localTemplates,
  ) {
    if (template is WorkoutTemplate) {
      var t = localTemplates
          .firstWhereOrNull((t) => t.workoutId == template.workoutId);
      return WorkoutCell2(
        workout: t ?? template,
        allowActions: t != null,
        isTemplate: t == null,
        showBookmark: true,
        bookmarkFilled: t != null,
      );
    } else {
      return WorkoutCell2(workout: template);
    }
  }
}

class ExpandableAnimatedList<T> extends StatefulWidget {
  final List<T> data;
  final int initialCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Duration animationDuration;
  final Duration staggerDelay;
  final String showMoreText;
  final String showLessText;
  final bool allowsExpand;
  final double borderRadius;
  final Border? border;

  const ExpandableAnimatedList({
    Key? key,
    required this.data,
    required this.itemBuilder,
    this.initialCount = 3,
    this.animationDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 40),
    this.showMoreText = 'Show More',
    this.showLessText = 'Show Less',
    this.allowsExpand = true,
    this.borderRadius = 16,
    this.border,
  }) : super(key: key);

  @override
  _ExpandableAnimatedListState<T> createState() =>
      _ExpandableAnimatedListState<T>();
}

class _ExpandableAnimatedListState<T> extends State<ExpandableAnimatedList<T>>
    with SingleTickerProviderStateMixin {
  late final GlobalKey<AnimatedListState> _listKey;
  late int _displayCount;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _listKey = GlobalKey<AnimatedListState>();
    if (widget.allowsExpand) {
      _displayCount = widget.initialCount < widget.data.length
          ? widget.initialCount
          : widget.data.length;
    } else {
      _displayCount = widget.data.length;
    }
  }

  @override
  void didUpdateWidget(ExpandableAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle data changes from parent
    if (widget.data.length != oldWidget.data.length) {
      // Adjust display count if data size changed
      if (!_expanded) {
        _displayCount = widget.initialCount < widget.data.length
            ? widget.initialCount
            : widget.data.length;
      } else {
        _displayCount = widget.data.length;
      }
    }
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        // Insert remaining items one by one with staggered animation
        final int insertCount = widget.data.length - _displayCount;
        for (int i = 0; i < insertCount; i++) {
          final insertIndex = _displayCount + i;
          Future.delayed(widget.staggerDelay * i, () {
            if (!mounted) return;
            _listKey.currentState?.insertItem(
              insertIndex,
              duration: widget.animationDuration,
            );
          });
        }
        _displayCount = widget.data.length;
      } else {
        // Remove down to initialCount
        final int removeCount = _displayCount - widget.initialCount;
        for (int i = 0; i < removeCount; i++) {
          final removeIndex = _displayCount - 1 - i;
          _listKey.currentState?.removeItem(
            removeIndex,
            (context, animation) => SizeTransition(
              sizeFactor: animation,
              child: widget.itemBuilder(context, removeIndex),
            ),
            duration: widget.animationDuration,
          );
        }
        _displayCount = widget.initialCount;
      }
    });
  }

  bool get _shouldShowButton => widget.data.length > widget.initialCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: widget.animationDuration,
          curve: Sprung.overDamped,
          child: ConstrainedBox(
            constraints: const BoxConstraints(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: widget.border ??
                    Border.all(
                      color: AppColors.border(context),
                      width: 3,
                    ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: AnimatedList(
                  key: _listKey,
                  padding: EdgeInsets.zero,
                  initialItemCount: _displayCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      child: widget.itemBuilder(context, index),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (_shouldShowButton && widget.allowsExpand)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Clickable(
              onTap: _toggle,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cell(context),
                  borderRadius: BorderRadius.circular(16),
                  border: widget.border ??
                      Border.all(
                        color: AppColors.border(context),
                        width: 3,
                      ),
                ),
                padding: EdgeInsets.all(8),
                child: Text(
                  _expanded ? widget.showLessText : widget.showMoreText,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

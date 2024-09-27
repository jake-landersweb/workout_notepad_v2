import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/utils/color.dart';

class CustomPageView extends StatefulWidget {
  final List<Widget> children;
  final void Function(int oldPage, int newPage)? onPageChange;
  final bool showIndicators;
  final Duration duration;
  final double childHorizontalPadding;

  const CustomPageView({
    Key? key,
    required this.children,
    this.onPageChange,
    this.showIndicators = true,
    this.duration = const Duration(milliseconds: 500),
    this.childHorizontalPadding = 0,
  }) : super(key: key);

  @override
  State<CustomPageView> createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late List<double> _heights;
  int _currentPage = 0;

  double get _currentHeight => _heights[_currentPage];

  @override
  void initState() {
    _heights = widget.children.map((e) => 0.0).toList();
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        final newPage = _pageController.page?.round() ?? 0;
        if (_currentPage != newPage) {
          if (widget.onPageChange != null) {
            widget.onPageChange!(_currentPage, newPage);
          }
          setState(() => _currentPage = newPage);
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showIndicators || widget.children.length < 2) {
      return _getChild(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _getChild(context),
        const SizedBox(height: 4),
        _footer(context),
      ],
    );
  }

  Widget _getChild(BuildContext context) {
    return ExpandablePageView.builder(
      controller: _pageController,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return Padding(
          padding:
              EdgeInsets.symmetric(horizontal: widget.childHorizontalPadding),
          child: Align(child: widget.children[index]),
        );
      },
    );
  }

  Widget _footer(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < widget.children.length; i++)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                color: i == _currentPage
                    ? AppColors.subtext(context)
                    : AppColors.light(context),
                shape: BoxShape.circle,
              ),
              height: 7,
              width: 7,
            ),
          ),
      ],
    );
  }
}

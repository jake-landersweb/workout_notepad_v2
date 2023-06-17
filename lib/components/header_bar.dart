// ignore_for_file: must_be_immutable
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sprung/sprung.dart';
import 'root.dart' as sui;

class HeaderBar extends StatefulWidget {
  HeaderBar({
    Key? key,
    this.title = "",
    this.children = const [],
    this.leading = const [],
    this.trailing = const [],
    this.isLarge = false,
    this.scrollController,
    this.itemBarPadding = const EdgeInsets.fromLTRB(16, 0, 16, 8),
    this.refreshable = false,
    this.onRefresh,
    this.horizontalSpacing = 16,
    this.bottomSpacing = 50,
    this.backgroundColor,
    this.canScroll = true,
    this.titleWidget,
    this.titleColor,
    this.hideKeyboardOnTap = true,
    this.hasSafeArea = true,
    this.barHeight = 40,
    this.leadingAlignment,
    this.titleAlignment,
    this.trailingAlignment,
    this.isFluid = false,
    this.itemSpacing = 16,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.animateOnAdd = false,
    this.largeTitlePadding = EdgeInsets.zero,
  }) : super(key: key);

  HeaderBar.sheet({
    super.key,
    required this.title,
    required this.children,
    this.leading = const [],
    this.trailing = const [],
    this.scrollController,
    this.itemBarPadding = const EdgeInsets.fromLTRB(16, 0, 16, 0),
    this.refreshable = false,
    this.onRefresh,
    this.horizontalSpacing = 16,
    this.bottomSpacing = 50,
    this.backgroundColor,
    this.canScroll = true,
    this.titleWidget,
    this.titleColor,
    this.hideKeyboardOnTap = true,
    this.isFluid = false,
    this.itemSpacing = 16,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.animateOnAdd = false,
    this.largeTitlePadding = EdgeInsets.zero,
  }) {
    // set sheet specific attributes
    isLarge = false;
    hasSafeArea = false;
    barHeight = 60;
    leadingAlignment = Alignment.centerLeft;
    titleAlignment = Alignment.center;
    trailingAlignment = Alignment.centerRight;
  }

  late String title;
  late List<Widget> children;
  late List<Widget> leading;
  late List<Widget> trailing;
  late bool isLarge;
  ScrollController? scrollController;
  late EdgeInsets itemBarPadding;
  late bool refreshable;
  AsyncCallback? onRefresh;
  late double horizontalSpacing;
  late double bottomSpacing;
  Color? backgroundColor;
  late bool canScroll;
  Widget? titleWidget;
  Color? titleColor;
  late bool hideKeyboardOnTap;
  late bool hasSafeArea;
  late double barHeight;
  Alignment? leadingAlignment;
  Alignment? titleAlignment;
  Alignment? trailingAlignment;
  final bool isFluid;
  final double itemSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final bool animateOnAdd;
  final EdgeInsets largeTitlePadding;

  @override
  _HeaderBarState createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  late double _barHeight;

  // whether to show the shadow or not
  bool _showElevation = false;

  // controls title scale for interactive changing
  double _titleScale = 1;

  // whether to show the small title when large title is active
  late bool _showSmallTitle;

  // progress for loading
  double _loadAmount = 0;

  // for determining if user scrolled enough to load
  bool _shouldLoad = false;

  // for getting amount to auto scroll by
  double _scrollAmount = 0;

  // for controlling scroll
  late ScrollController _scrollController;

  @override
  void initState() {
    // some assertions
    super.initState();
    _barHeight = widget.barHeight;
    // set up scroll controller
    if (widget.scrollController == null) {
      _scrollController = ScrollController();
    } else {
      _scrollController = widget.scrollController!;
    }

    // set up whether to show large title or not
    if (widget.isLarge) {
      _showSmallTitle = false;
    } else {
      _showSmallTitle = true;
    }

    // add logic to scroll controller
    _scrollController.addListener(() {
      if (_scrollController.offset > 0) {
        /** When scroll is pushing up */

        // for when title large
        if (widget.isLarge) {
          // set title scale to 1
          if (_titleScale != 1) {
            setState(() {
              _titleScale = 1;
            });
          }
        }
      } else {
        /** for when scroll is pulling down */

        // increse the title scale when pulling down and
        // FOR ONLY LARGE
        // FOR NOT REFRESHABLE
        if (widget.isLarge && !widget.refreshable) {
          setState(() {
            _titleScale = 1 + (-_scrollController.offset * 0.0005);
            _showSmallTitle =
                false; // make sure title is hidden on faster scroll
          });
        }
      }
      /** EVERYTHING BELOW IS GLOBAL FOR SCROLLING UP AND DOWN */

      // show elevation indicators soon after scroll
      // FOR BOTH SMALL AND LARGE
      if (_scrollController.offset > 10) {
        setState(() {
          _showElevation = true;
        });
      } else {
        setState(() {
          _showElevation = false;
        });
      }

      // FOR CONTROLLING SHOWING AND HIDING SMALL TITLE
      // ONLY WHEN LARGE
      if (widget.isLarge) {
        if (_scrollController.offset > 30) {
          setState(() {
            _showSmallTitle = true;
          });
        } else if (_scrollController.offset < 10) {
          setState(() {
            _showSmallTitle = false;
          });
        }
      }

      // ONLY FOR REFRESHABLE
      if (widget.refreshable) {
        setState(() {
          _loadAmount = -0.2 + -(_scrollController.offset * 0.012);
        });
        // control if the view should reload when the user releases the screen
        if (_loadAmount >= 1) {
          _shouldLoad = true;
        } else {
          _shouldLoad = false;
        }
      }
    });
  }

  void _refreshAction() async {
    await widget.onRefresh!();
    setState(() {
      _shouldLoad = false;
      _scrollAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // dismiss keyboard on tap
        if (widget.hideKeyboardOnTap) {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        }
      },
      child: Container(
        color:
            widget.backgroundColor ?? Theme.of(context).colorScheme.background,
        child: SafeArea(
          top: false,
          bottom: false,
          left: false,
          right: false,
          child: Stack(
            children: [
              AnimatedPadding(
                duration: const Duration(milliseconds: 800),
                curve: Sprung.overDamped,
                padding: EdgeInsets.only(top: -_scrollAmount / 2),
                child: _body(context),
              ),
              _titleBar(context),
              if (widget.refreshable)
                Padding(
                  padding: EdgeInsets.only(
                      top: (widget.hasSafeArea
                              ? MediaQuery.of(context).viewPadding.top
                              : 0) +
                          (widget.isLarge ? 0 : 40) +
                          10),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _scrollAmount != 0
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary)
                        : CircularProgressIndicator(
                            value: _loadAmount,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalSpacing),
      child: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (!notification.toString().contains("DragUpdateDetails") &&
              !notification.toString().contains("direction")) {
            // user released the screen, animate the position change
            if (_scrollAmount == 0 && _shouldLoad) {
              setState(() {
                _scrollAmount = _scrollController.offset;
              });
              _refreshAction();
            }
          }
          return true;
        },
        child: widget.canScroll
            ? widget.isFluid
                ? sui.FluidScrollView(
                    controller: _scrollController,
                    spacing: widget.itemSpacing,
                    crossAxisAlignment: widget.crossAxisAlignment,
                    children: _children(context),
                  )
                : ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    physics: Platform.isIOS
                        ? const AlwaysScrollableScrollPhysics()
                        : const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                    children: _children(context),
                  )
            : Column(
                children: widget.children,
              ),
      ),
    );
  }

  List<Widget> _children(BuildContext context) {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: (widget.hasSafeArea
                    ? MediaQuery.of(context).viewPadding.top
                    : 0) +
                _barHeight,
          ),
          if (widget.isLarge)
            // scalable large title
            Padding(
              padding: widget.largeTitlePadding,
              child: Transform.scale(
                alignment: Alignment.centerLeft,
                scale: _titleScale > 1 ? _titleScale : 1,
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: widget.titleColor ??
                        Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
            ),
        ],
      ),
      for (var i in widget.children)
        widget.animateOnAdd ? _AppBarAnimatedCell(child: i) : i,
      SizedBox(height: widget.bottomSpacing),
    ];
  }

  Widget _titleBar(BuildContext context) {
    return Column(
      children: [
        sui.BlurredContainer(
          width: double.infinity,
          borderRadius: BorderRadius.circular(0),
          backgroundColor: widget.backgroundColor ??
              Theme.of(context).colorScheme.background,
          opacity: _showElevation ? 0.7 : 0,
          blur: _showElevation ? 10 : 0,
          child: Column(
            children: [
              if (widget.hasSafeArea)
                SizedBox(height: MediaQuery.of(context).viewPadding.top),
              SizedBox(
                height: _barHeight,
                child: Padding(
                  padding: widget.itemBarPadding,
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Align(
                          alignment:
                              widget.leadingAlignment ?? Alignment.bottomLeft,
                          child: Row(children: widget.leading),
                        ),
                        Align(
                          alignment:
                              widget.trailingAlignment ?? Alignment.bottomRight,
                          child: Row(children: [
                            const Spacer(),
                            Row(children: widget.trailing),
                          ]),
                        ),
                        if (widget.title.isNotEmpty)
                          Align(
                            alignment:
                                widget.titleAlignment ?? Alignment.bottomCenter,
                            child: widget.titleWidget != null
                                ? widget.titleWidget!
                                : AnimatedOpacity(
                                    opacity: _showSmallTitle ? 1 : 0,
                                    duration: const Duration(milliseconds: 150),
                                    child: Text(
                                      widget.title.length > 25
                                          ? "${widget.title.substring(0, 25)}..."
                                          : widget.title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: widget.titleColor ??
                                            Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                      ),
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // for showing divider between bar and view
        AnimatedOpacity(
          opacity: _showElevation ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            height: 0.5,
            indent: 0,
            endIndent: 0,
          ),
        ),
      ],
    );
  }
}

class _AppBarAnimatedCell extends StatefulWidget {
  const _AppBarAnimatedCell({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  State<_AppBarAnimatedCell> createState() => __AppBarAnimatedCellState();
}

class __AppBarAnimatedCellState extends State<_AppBarAnimatedCell>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
      value: 0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Sprung.overDamped,
    );
    // open container if is expanded
    _controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(sizeFactor: _animation, child: widget.child);
  }
}

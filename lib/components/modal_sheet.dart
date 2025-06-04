// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/utils/color.dart';

class ModalSheetController {
  final VoidCallback dismiss;
  ModalSheetController(this.dismiss);
}

class ModalSheet {
  // Change from single overlay to a stack of overlays
  static final List<OverlayEntry> _overlayStack = [];
  static final List<_ModalWidgetState> _stateStack = [];

  static void dismissAll() {
    // Dismiss all modals in reverse order (top to bottom)
    while (_stateStack.isNotEmpty) {
      final state = _stateStack.last;
      if (state.mounted) {
        state.dismiss();
      } else {
        // Fallback cleanup
        _stateStack.removeLast();
        if (_overlayStack.isNotEmpty) {
          _overlayStack.removeLast().remove();
        }
      }
    }
  }

  static void dismissTop() {
    if (_stateStack.isNotEmpty) {
      final state = _stateStack.last;
      if (state.mounted) {
        state.dismiss();
      } else {
        // Fallback cleanup
        _stateStack.removeLast();
        if (_overlayStack.isNotEmpty) {
          _overlayStack.removeLast().remove();
        }
      }
    }
  }

  static int get modalCount => _overlayStack.length;

  static void show({
    required BuildContext context,
    required Widget Function(BuildContext, ScrollController, GlobalKey) builder,
    double? height, // If null, defaults to full screen height
    GlobalKey? scrollableContentKey,
    bool? showDebugHeader,
    bool? insertAbove, // New parameter to control insertion level
    bool? hasSafeArea,
  }) {
    final overlay = Overlay.of(context);
    final scrollController = ScrollController();

    void onDismiss() {
      // Find and remove this specific overlay
      final overlayEntry = _overlayStack.isNotEmpty ? _overlayStack.last : null;
      if (overlayEntry != null) {
        overlayEntry.remove();
        _overlayStack.removeLast();
        _stateStack.removeLast();
      }
    }

    final overlayEntry = OverlayEntry(
      builder: (context) => _ModalWidget(
        builder: builder,
        scrollController: scrollController,
        height: height,
        onDismiss: onDismiss,
        showDebugHeader: showDebugHeader ?? false,
        modalIndex: _overlayStack.length, // Pass the current stack index
        hasSafeArea: hasSafeArea ?? true,
      ),
    );

    // Add to our tracking lists
    _overlayStack.add(overlayEntry);

    // Insert with proper z-ordering
    if (insertAbove == true) {
      // Insert above other navigation components
      overlay.insert(overlayEntry,
          above: overlay.widget.initialEntries.lastOrNull);
    } else {
      // Default insertion (may appear under navigation)
      overlay.insert(overlayEntry);
    }
  }

  // Add convenience method for dismissing specific modal by index
  static void dismissAtIndex(int index) {
    if (index >= 0 && index < _stateStack.length) {
      final state = _stateStack[index];
      if (state.mounted) {
        state.dismiss();
      }
    }
  }
}

// Add this inherited widget above _DebugModalWidget class
class _DebugModalInherited extends InheritedWidget {
  final ModalSheetController controller;
  final int modalIndex;
  final int totalModals;

  const _DebugModalInherited({
    required this.controller,
    required this.modalIndex,
    required this.totalModals,
    required super.child,
  });

  static _DebugModalInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_DebugModalInherited>();
  }

  @override
  bool updateShouldNotify(_DebugModalInherited oldWidget) =>
      modalIndex != oldWidget.modalIndex ||
      totalModals != oldWidget.totalModals;
}

class _ModalWidget extends StatefulWidget {
  final Widget Function(BuildContext, ScrollController, GlobalKey) builder;
  final ScrollController scrollController;
  final double? height;
  final VoidCallback onDismiss;
  final bool showDebugHeader;
  final int modalIndex;
  final bool hasSafeArea;

  const _ModalWidget({
    required this.builder,
    required this.scrollController,
    this.height,
    required this.onDismiss,
    this.showDebugHeader = false,
    required this.modalIndex,
    this.hasSafeArea = true,
  });

  @override
  State<_ModalWidget> createState() => _ModalWidgetState();
}

class _ModalWidgetState extends State<_ModalWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _snapBackController;
  late AnimationController _dismissController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _snapBackAnimation;
  late Animation<double> _dismissAnimation;

  late Widget _builtChildContent;

  double _dragOffset = 0.0;
  double _snapBackStartOffset = 0.0;
  bool _isDragging = false;
  bool _isSnappingBack = false;
  bool _isDismissing = false;
  bool _isDismissingFromDrag = false;

  bool _isTrackingPointer = false;
  bool _shouldInterceptGesture = false;
  double _pointerStartY = 0.0;
  double _interceptStartY = 0.0;
  int? _primaryPointerId;

  bool _isPointerInHeader = false;
  bool _isPointerInGeneralContent = false;
  bool _isPointerInSpecificScrollableContent = false;

  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();
  final GlobalKey _scrollableContentKey = GlobalKey();

  static const double _gestureThreshold = 20.0;

  // Animation constants
  static const double _minScale = 0.8;
  static const double _maxScale = 1.0;
  static const double _dismissThresholdRatio = 0.4; // 40% of screen height

  @override
  void initState() {
    super.initState();
    // Add this state to the stack instead of replacing
    if (widget.modalIndex < ModalSheet._stateStack.length) {
      ModalSheet._stateStack[widget.modalIndex] = this;
    } else {
      ModalSheet._stateStack.add(this);
    }

    // Animation controllers setup
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _snapBackController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    _dismissController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutCubic));
    _snapBackAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _snapBackController, curve: Curves.easeOutCubic));
    _dismissAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _dismissController, curve: Curves.easeInCubic));

    _builtChildContent =
        widget.builder(context, widget.scrollController, _scrollableContentKey);

    widget.scrollController.addListener(_onScrollChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScrollChanged);
    _animationController.dispose();
    _snapBackController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  // Add public dismiss method
  void dismiss() {
    _dismiss();
  }

  void _onScrollChanged() {
    if (!mounted || !widget.scrollController.hasClients) return;
    setState(() {
      // _canDrag logic can remain if you still want header-only drag when scrolled
    });
  }

  bool _isPointerInArea(Offset globalPosition, GlobalKey key) {
    final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return false;
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    return globalPosition.dx >= position.dx &&
        globalPosition.dx <= position.dx + size.width &&
        globalPosition.dy >= position.dy &&
        globalPosition.dy <= position.dy + size.height;
  }

  bool _shouldAllowDragFromScrollableContent() {
    if (!widget.scrollController.hasClients) return true;
    return widget.scrollController.position.pixels <= 0;
  }

  // Get the dismiss threshold in pixels
  double get _dismissThreshold {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * _dismissThresholdRatio;
  }

  void _onPointerDown(PointerDownEvent event) {
    _primaryPointerId = event.pointer;
    _isTrackingPointer = true;
    _shouldInterceptGesture = false;
    _pointerStartY = event.position.dy;
    _interceptStartY = 0.0;

    _isPointerInHeader = _isPointerInArea(event.position, _headerKey);
    _isPointerInGeneralContent = _isPointerInArea(event.position, _contentKey);
    _isPointerInSpecificScrollableContent =
        _isPointerInArea(event.position, _scrollableContentKey);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isTrackingPointer || event.pointer != _primaryPointerId) return;

    final deltaY = event.position.dy - _pointerStartY;
    bool determinedShouldAllowDrag = false;
    if (_isPointerInHeader) {
      determinedShouldAllowDrag = true;
    } else if (_isPointerInGeneralContent) {
      if (_isPointerInSpecificScrollableContent) {
        determinedShouldAllowDrag = _shouldAllowDragFromScrollableContent();
      } else {
        determinedShouldAllowDrag = true;
      }
    }

    if (!_shouldInterceptGesture &&
        deltaY > _gestureThreshold &&
        determinedShouldAllowDrag) {
      _interceptStartY = event.position.dy;
      setState(() {
        _shouldInterceptGesture = true;
        _isDragging = true;
        _dragOffset = 0.0;
      });
      if (_isSnappingBack) {
        _snapBackController.stop();
        setState(() => _isSnappingBack = false);
      }
    } else if (_shouldInterceptGesture && _isDragging) {
      final dragDelta = event.position.dy - _interceptStartY;
      setState(() {
        _dragOffset = dragDelta.clamp(0.0, double.infinity);
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_isTrackingPointer || event.pointer != _primaryPointerId) return;
    if (_shouldInterceptGesture && _isDragging) {
      _handleDragEnd();
    }
    _resetPointerTracking();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer == _primaryPointerId) {
      if (_shouldInterceptGesture && _isDragging) {
        _snapBack();
      }
      _resetPointerTracking();
    }
  }

  void _resetPointerTracking() {
    _isTrackingPointer = false;
    _shouldInterceptGesture = false;
    _primaryPointerId = null;
    _pointerStartY = 0.0;
    _interceptStartY = 0.0;
    _isPointerInHeader = false;
    _isPointerInGeneralContent = false;
    _isPointerInSpecificScrollableContent = false;
  }

  void _handleDragEnd() {
    final shouldDismiss = _dragOffset > _dismissThreshold;
    setState(() => _isDragging = false);
    if (shouldDismiss) {
      _dismissFromDrag();
    } else {
      _snapBack();
    }
  }

  void _dismiss() {
    // Button dismiss - regular behavior
    if (_isDismissing ||
        (_animationController.status != AnimationStatus.completed &&
            _animationController.status != AnimationStatus.forward)) {
      return;
    }

    setState(() {
      _isDismissingFromDrag = false; // This is a button dismiss
    });

    _animationController.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  void _dismissFromDrag() {
    setState(() {
      _isDismissing = true;
      _isDismissingFromDrag = true; // This is a drag dismiss
    });
    _dismissController.reset();
    _dismissController.forward().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  void _snapBack() {
    setState(() {
      _isSnappingBack = true;
      _snapBackStartOffset = _dragOffset;
    });
    _snapBackController.reset();
    _snapBackController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isSnappingBack = false;
          _dragOffset = 0.0;
          _snapBackStartOffset = 0.0;
        });
      }
    });
  }

  double get _modalHeight {
    final mediaQuery = MediaQuery.of(context);
    return widget.height ?? mediaQuery.size.height;
  }

  // Calculate progress for blur effects
  double get _modalProgress {
    final modalHeight = _modalHeight;
    if (modalHeight == 0) return 0.0;

    double currentOffset;
    if (_isDragging) {
      // During drag, use drag offset for progress calculation
      currentOffset = _dragOffset;
    } else if (_isSnappingBack) {
      currentOffset = _snapBackStartOffset * _snapBackAnimation.value;
    } else if (_isDismissing && _isDismissingFromDrag) {
      // For drag dismiss, maintain the progress from when dismiss started
      final screenHeight = MediaQuery.of(context).size.height;
      final dismissProgress = _dismissAnimation.value;
      // Start from current drag progress and increase
      currentOffset = _dragOffset + (screenHeight * dismissProgress);
    } else if (_isDismissing && !_isDismissingFromDrag) {
      // For button dismiss, use normal slide animation
      currentOffset = modalHeight * _dismissAnimation.value;
    } else {
      // Initial slide in
      currentOffset = modalHeight * _slideAnimation.value;
    }

    return (currentOffset / modalHeight).clamp(0.0, 1.0);
  }

  // Calculate scale based on drag progress relative to dismiss threshold
  double get _currentScale {
    if (_isDragging || _isSnappingBack) {
      if (_dismissThreshold == 0) return _maxScale;

      double dragProgress;
      if (_isDragging) {
        // Scale reaches minimum (0.8) exactly when dismiss threshold is met
        dragProgress = (_dragOffset / _dismissThreshold).clamp(0.0, 1.0);
      } else {
        // Snapping back
        final currentDragOffset =
            _snapBackStartOffset * _snapBackAnimation.value;
        dragProgress = (currentDragOffset / _dismissThreshold).clamp(0.0, 1.0);
      }

      // Scale from 1.0 to 0.8 based on drag progress to dismiss threshold
      return _maxScale - ((_maxScale - _minScale) * dragProgress);
    } else if (_isDismissing && _isDismissingFromDrag) {
      // Maintain the scale from when dismiss started
      return _minScale;
    } else {
      // Normal scale for button dismiss and initial animation
      return _maxScale;
    }
  }

  // Calculate translation offset
  double get _currentOffset {
    if (_isDragging || _isSnappingBack) {
      // During drag and snap back, no translation (only scaling)
      return 0.0;
    } else if (_isDismissing && _isDismissingFromDrag) {
      // Drag dismiss: translate down from current position
      final screenHeight = MediaQuery.of(context).size.height;
      return screenHeight * _dismissAnimation.value;
    } else if (_isDismissing && !_isDismissingFromDrag) {
      // Button dismiss: normal slide down animation
      final modalHeight = _modalHeight;
      return modalHeight * _dismissAnimation.value;
    } else {
      // Initial slide in animation
      final modalHeight = _modalHeight;
      return modalHeight * _slideAnimation.value;
    }
  }

  static const double _minRadius = 10;
  static const double _maxRadius = 40;

  double get _cornerRadius {
    if (_isDismissing && _isDismissingFromDrag) {
      return _minRadius;
    }

    // For all other states, calculate based on drag progress to dismiss threshold
    double progress;
    if (_isDragging || _isSnappingBack) {
      if (_dismissThreshold == 0) {
        progress = 0.0;
      } else {
        double dragProgress;
        if (_isDragging) {
          dragProgress = (_dragOffset / _dismissThreshold).clamp(0.0, 1.0);
        } else {
          final currentDragOffset =
              _snapBackStartOffset * _snapBackAnimation.value;
          dragProgress =
              (currentDragOffset / _dismissThreshold).clamp(0.0, 1.0);
        }
        progress = dragProgress;
      }
    } else {
      // Use modal progress for other states
      progress = _modalProgress;
    }

    const baseRadius = _minRadius;
    const maxRadius = _maxRadius;
    return baseRadius +
        (maxRadius - baseRadius) * (1.0 - (progress.isNaN ? 0.0 : progress));
  }

  double get _blurIntensity {
    final progress = _modalProgress;
    const maxBlur = 16.0;

    return maxBlur *
        (1.0 - (progress.isNaN ? 0.0 : progress)) *
        _fadeAnimation.value;
  }

  @override
  Widget build(BuildContext context) {
    final modalHeight = _modalHeight;
    final scrollPos = widget.scrollController.hasClients
        ? widget.scrollController.position.pixels
        : 0.0;
    final theme = Theme.of(context);
    ;

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_animationController, _snapBackController, _dismissController]),
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: _blurIntensity, sigmaY: _blurIntensity),
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    color: Colors.black.withOpacity(
                        (0.3 * _fadeAnimation.value) / (widget.modalIndex + 1)),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Listener(
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerCancel,
                behavior: HitTestBehavior.translucent,
                child: Transform.translate(
                  offset: Offset(0, _currentOffset),
                  child: Transform.scale(
                    scale: _currentScale,
                    child: Container(
                      height: modalHeight,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius:
                            BorderRadius.all(Radius.circular(_cornerRadius)),
                        // Add subtle shadow for stacked appearance
                        boxShadow: widget.modalIndex > 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, -5),
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(_cornerRadius)),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                if (widget.showDebugHeader)
                                  Container(
                                    key: _headerKey,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    color: theme.colorScheme.surfaceVariant
                                        .withOpacity(0.5),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme.onSurfaceVariant
                                                .withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(2.5),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Modal ${widget.modalIndex + 1}/${ModalSheet.modalCount}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          'H:$_isPointerInHeader GenC:$_isPointerInGeneralContent SpecC:$_isPointerInSpecificScrollableContent',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          'CanDragScroll: ${_shouldAllowDragFromScrollableContent()} | Scroll: ${scrollPos.toStringAsFixed(1)} | Scale: ${_currentScale.toStringAsFixed(2)}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          'DragOffset: ${_dragOffset.toStringAsFixed(1)} | Threshold: ${_dismissThreshold.toStringAsFixed(1)} | CornerRadius: ${_cornerRadius.toStringAsFixed(1)}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  child: Scaffold(
                                    body: Container(
                                      key: _contentKey,
                                      child: _DebugModalInherited(
                                        controller:
                                            ModalSheetController(dismiss),
                                        modalIndex: widget.modalIndex,
                                        totalModals: ModalSheet.modalCount,
                                        child: AnimatedBuilder(
                                          animation: Listenable.merge([
                                            _snapBackController,
                                            _dismissController,
                                            _animationController
                                          ]),
                                          child:
                                              _builtChildContent, // <<< PASS THE PRE-BUILT CHILD HERE
                                          builder:
                                              (context, preBuiltContentChild) {
                                            // preBuiltContentChild is _builtChildContent
                                            double contentOpacity = 1.0;
                                            final progress = _modalProgress;
                                            if (_isDismissing ||
                                                _slideAnimation.value > 0) {
                                              contentOpacity = 1.0 -
                                                  (progress.isNaN
                                                      ? 0.0
                                                      : progress);
                                            }

                                            // Conditionally wrap the pre-built child with AbsorbPointer
                                            Widget finalContent = AbsorbPointer(
                                              absorbing:
                                                  _shouldInterceptGesture, // Toggle based on state
                                              child: preBuiltContentChild!,
                                            );

                                            return Opacity(
                                              opacity: contentOpacity.clamp(
                                                  0.3, 1.0),
                                              child:
                                                  finalContent, // Use the (potentially wrapped) pre-built child
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Dismiss Button
                            Positioned(
                              top: 0,
                              right: 0,
                              child: SafeArea(
                                left: false,
                                bottom: false,
                                right: false,
                                top: widget.hasSafeArea,
                                child: Padding(
                                  padding: widget.hasSafeArea
                                      ? const EdgeInsets.fromLTRB(0, 0, 16, 10)
                                      : const EdgeInsets.fromLTRB(0, 16, 16, 0),
                                  child: Clickable(
                                    key: ValueKey("close-modal-widget"),
                                    onTap: _dismiss,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.cell(context),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Add this extension method at the bottom of the file
extension ModalSheetExtension on BuildContext {
  void dismissDebugModalSheet() {
    final inherited = _DebugModalInherited.of(this);
    inherited?.controller.dismiss(); // Fix: Access controller property first
  }

  // Add new extension methods for stack management
  int get modalStackCount {
    final inherited = _DebugModalInherited.of(this);
    return inherited?.totalModals ?? 0;
  }

  int get modalIndex {
    final inherited = _DebugModalInherited.of(this);
    return inherited?.modalIndex ?? -1;
  }
}

// Helper function updated
void showModalSheet({
  required BuildContext context,
  required Widget Function(BuildContext, ScrollController, GlobalKey) builder,
  double? height, // If null, defaults to full screen height
  GlobalKey? scrollableContentKey,
  bool? insertAbove, // New parameter
  bool? hasSafeArea,
}) {
  ModalSheet.show(
    context: context,
    builder: builder,
    height: height,
    scrollableContentKey: scrollableContentKey,
    insertAbove: insertAbove,
    hasSafeArea: hasSafeArea ?? true,
  );
}

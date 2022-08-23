import 'package:flutter/material.dart';
import 'package:nested_side_sheet/src/side_sheet_host.dart';
import 'package:nested_side_sheet/src/utils/measure_size.dart';

class AnimatedSideSheet extends StatefulWidget {
  /// Highlight of the program - the content of the side sheet.
  final Widget child;

  /// Add a sheet with animation
  final bool initWithAnimation;

  /// Sheet animation controller
  final AnimationController animationController;

  /// Custom animation transition builder
  final SideSheetTransitionBuilder transitionBuilder;

  const AnimatedSideSheet({
    Key? key,
    required this.child,
    required this.animationController,
    required this.initWithAnimation,
    required this.transitionBuilder,
  }) : super(key: key);

  @override
  State<AnimatedSideSheet> createState() => _AnimatedSideSheetState();
}

class _AnimatedSideSheetState extends State<AnimatedSideSheet>
    with TickerProviderStateMixin {
  late ValueNotifier<Size?> sheetSizeNotifier;

  late final AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    sheetSizeNotifier = ValueNotifier(null);
    animationController = widget.animationController;
    animation = ProxyAnimation(animationController);

    super.initState();
  }

  void animate() async {
    if (widget.initWithAnimation) {
      await animationController.forward();
    } else {
      animationController.value = 1;
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) => widget.transitionBuilder(child!, animation),
        child: MeasureSize(
          onChange: (size) {
            sheetSizeNotifier.value ??= size;
            animate();
          },
          child: RepaintBoundary(
            child: ValueListenableBuilder<Size?>(
              valueListenable: sheetSizeNotifier,
              builder: (context, size, child) => SizedBox.fromSize(
                size: size,
                child: child,
              ),
              child: RepaintBoundary(child: widget.child),
            ),
          ),
        ),
      );
}

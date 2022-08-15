import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/measure_size.dart';
import 'package:krootl_flutter_side_menu/src/type_defs.dart';

class SlidingAnimationWidget extends StatefulWidget {
  /// the guest of the program =)
  final Widget child;

  /// add a sheet without animation
  final bool initWithAnimation;

  final AnimationController animationController;

  /// custom animation transition builder
  final SheetTransitionBuilder transitionBuilder;

  const SlidingAnimationWidget({
    Key? key,
    required this.child,
    required this.animationController,
    required this.initWithAnimation,
    required this.transitionBuilder,
  }) : super(key: key);

  @override
  State<SlidingAnimationWidget> createState() => _SlidingAnimationWidgetState();
}

class _SlidingAnimationWidgetState extends State<SlidingAnimationWidget>
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
          child: ValueListenableBuilder<Size?>(
            valueListenable: sheetSizeNotifier,
            builder: (context, size, child) => SizedBox.fromSize(
              size: size,
              child: widget.child,
            ),
          ),
        ),
      );
}

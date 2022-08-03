import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/measure_size.dart';

class SlidingAnimationWidget extends StatefulWidget {
  final Widget child;

  /// usage: when you replace sheet, an animation of showing is an unnecessary
  final bool initWithAnimation;

  final AnimationController animationController;

  /// custom animation transition
  final AnimatedWidget Function(
    Widget child,
    Animation<double> animation,
  ) transitionAnimation;

  const SlidingAnimationWidget({
    Key? key,
    required this.child,
    required this.animationController,
    required this.initWithAnimation,
    required this.transitionAnimation,
  }) : super(key: key);

  @override
  State<SlidingAnimationWidget> createState() => _SlidingAnimationWidgetState();
}

class _SlidingAnimationWidgetState extends State<SlidingAnimationWidget>
    with TickerProviderStateMixin {
  Size? sheetSize;

  late final AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    animationController = widget.animationController;
    super.initState();

    animation = ProxyAnimation(animationController);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (sheetSize != null) animate();
      },
    );
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
        builder: (context, child) => widget.transitionAnimation(child!, animation),
        child: SizedBox(
          width: sheetSize?.width,
          height: sheetSize?.height,
          child: MeasureSize(
            onChange: (size) {
              setState(() => sheetSize ??= size);
              animate();
            },
            child: widget.child,
          ),
        ),
      );
}

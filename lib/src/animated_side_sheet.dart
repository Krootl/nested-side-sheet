import 'package:flutter/material.dart';
import 'package:nested_side_sheet/src/side_sheet_host.dart';

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
  late final AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    animationController = widget.animationController;
    animation = ProxyAnimation(animationController);
    WidgetsBinding.instance.addPostFrameCallback((_) => animate());
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
        builder: (context, child) =>
            widget.transitionBuilder(child!, animation),
        child: widget.child,
      );
}

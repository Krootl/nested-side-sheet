import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/measure_size.dart';

class SlidingAnimationWidget extends StatefulWidget {
  final Widget child;

  final bool initWithAnimation;

  final AnimationController animationController;

  /// custom animation transition
  final AnimatedWidget Function(
    Widget child,
    Animation<Offset> position,
  ) transitionAnimation;

  final Tween<Offset> tweenTransition;

  const SlidingAnimationWidget({
    Key? key,
    required this.child,
    required this.animationController,
    this.initWithAnimation = true,
    required this.tweenTransition,
    required this.transitionAnimation,
  }) : super(key: key);

  @override
  State<SlidingAnimationWidget> createState() => _SlidingAnimationWidgetState();
}

class _SlidingAnimationWidgetState extends State<SlidingAnimationWidget>
    with TickerProviderStateMixin {
  Size? sheetSize;

  late final AnimationController _animationController;
  late Animation<Offset> _animationSlide;

  @override
  void initState() {
    _animationController = widget.animationController;
    super.initState();

    _animationSlide = getTween(widget.initWithAnimation).animate(
      _animationController,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (sheetSize != null) animate();
      },
    );
  }

  Tween<Offset> getTween(bool withAnimation) {
    final tween = widget.tweenTransition;
    return withAnimation
        ? tween
        : Tween<Offset>(
            begin: tween.end,
            end: Offset.zero,
          );
  }

  void animate() async {
    await _animationController.forward();
    if (_animationController.isCompleted) {
      _animationSlide = getTween(true).animate(
        _animationController,
      );
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationSlide,
        builder: (context, child) => widget.transitionAnimation(child!, _animationSlide),
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

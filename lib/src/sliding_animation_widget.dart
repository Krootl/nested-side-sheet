import 'package:flutter/material.dart';

class SlidingAnimationWidget extends StatefulWidget {
  final double sheetWidth;
  final Widget child;

  final bool initWithAnimation;

  final AnimationController animationController;

  const SlidingAnimationWidget({
    Key? key,
    required this.sheetWidth,
    required this.child,
    required this.animationController,
    this.initWithAnimation = true,
  }) : super(key: key);

  @override
  State<SlidingAnimationWidget> createState() => _SlidingAnimationWidgetState();
}

class _SlidingAnimationWidgetState extends State<SlidingAnimationWidget>
    with TickerProviderStateMixin {
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
        await _animationController.forward();
        if (_animationController.isCompleted) {
          _animationSlide = getTween(true).animate(
            _animationController,
          );
        }
      },
    );
  }

  Tween<Offset> getTween(bool withAnimation) => Tween<Offset>(
        begin: withAnimation ? const Offset(1, 0) : Offset.zero,
        end: Offset.zero,
      );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationSlide,
        builder: (context, child) => SlideTransition(
          position: _animationSlide,
          child: child,
        ),
        child: SizedBox(
          width: widget.sheetWidth,
          height: double.infinity,
          child: widget.child,
        ),
      );
}

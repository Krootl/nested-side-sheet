import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  const HomeCard({
    this.child,
    this.backgroundColor,
    this.height,
    this.shadows,
    Key? key,
  }) : super(key: key);

  final List<BoxShadow>? shadows;
  final Widget? child;
  final Color? backgroundColor;
  final double? height;

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(top: kToolbarHeight, right: kToolbarHeight),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shadows: shadows,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
            ),
          ),
        ),
        child: child,
      );
}

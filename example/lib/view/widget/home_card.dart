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
        margin: EdgeInsets.only(top: 48, right: 48),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: shadows,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
          ),
        ),
        child: child,
      );
}

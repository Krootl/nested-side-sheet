import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  const HomeCard({
    this.child,
    this.backgroundColor,
    this.height,
    Key? key,
  }) : super(key: key);

  final Widget? child;
  final Color? backgroundColor;
  final double? height;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Scrollbar(
                scrollbarOrientation: ScrollbarOrientation.bottom,
                child: SingleChildScrollView(
                  primary: true,
                  scrollDirection: Axis.horizontal,
                  child: content(
                    context,
                    pageWidth: constraints.maxWidth,
                    pageHeight: constraints.minHeight,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget content(
    BuildContext context, {
    required double pageWidth,
    required double pageHeight,
  }) =>
      Container(
        constraints: BoxConstraints(
          maxWidth: pageWidth - 60,
          minHeight: height ?? pageHeight,
        ),
        margin: EdgeInsets.only(top: 60),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40),
          ),
        ),
        child: child,
      );
}

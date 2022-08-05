import 'package:flutter/widgets.dart';
import 'package:krootl_flutter_side_menu/krootl_flutter_sheet.dart';

/// Examples of custom transition animation
class NavigateTo {
  NavigateTo._();

  /// navigate to the next sheet from the left side of the screen
  static Future<dynamic> pushLeft(BuildContext context, Widget sheet) =>
      SheetWidget.of(context).push(
        sheet,
        alignment: Alignment.centerLeft,
        transitionBuilder: (child, animation) => SlideTransition(
          position: animation.drive(
            Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero),
          ),
          child: child,
        ),
      );

  /// navigate to the next sheet from the bottom side of the screen
  static Future<dynamic> pushBottom(BuildContext context, Widget sheet) =>
      SheetWidget.of(context).push(
        sheet,
        alignment: Alignment.bottomCenter,
        transitionBuilder: (child, animation) => SlideTransition(
          position: animation
              .drive(CurveTween(curve: Curves.easeOutCubic))
              .drive(Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)),
          child: child,
        ),
      );
}

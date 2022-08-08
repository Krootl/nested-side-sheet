import 'dart:async';

import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/sliding_animation_widget.dart';
import 'package:krootl_flutter_side_menu/src/type_defs.dart';

class SheetEntry<T> {
  /// unique value
  final String id;

  /// the wrapped widget
  final SlidingAnimationWidget slidingAnimationWidget;

  /// the sheet's controller
  final AnimationController animationController;

  /// custom animation transition builder
  final SheetTransitionBuilder transitionBuilder;

  /// a unique completer for getting a feature result
  final Completer<T?> completer;

  /// which the side do you want to animate a sheet
  final Alignment alignment;

  /// an ability to close sheets by the tapping on the free space
  final bool dismissible;

  /// /// The decoration builder to paint behind the [slidingAnimationWidget].
  final DecorationBuilder? decorationBuilder;

  SheetEntry({
    required this.id,
    required this.slidingAnimationWidget,
    required this.animationController,
    required this.completer,
    required this.transitionBuilder,
    required this.alignment,
    required this.dismissible,
    required this.decorationBuilder,
  });

  factory SheetEntry.createNewElement({
    required AnimatedWidget Function(Widget child, Animation<double> animation) transitionBuilder,
    required TickerProvider tickerProvider,
    required Duration animationDuration,
    required Widget sheet,
    required Completer<T?> completer,
    required Alignment alignment,
    required DecorationBuilder? decorationBuilder,
    bool initWithAnimation = true,
    required bool dismissible,
  }) {
    final uniqueId = UniqueKey().toString();

    final animationController = AnimationController(
      vsync: tickerProvider,
      duration: animationDuration,
    );

    final animatedSheet = SlidingAnimationWidget(
      key: ValueKey(uniqueId),
      transitionBuilder: transitionBuilder,
      animationController: animationController,
      initWithAnimation: initWithAnimation,
      child: sheet,
    );

    return SheetEntry<T>(
      id: uniqueId,
      slidingAnimationWidget: animatedSheet,
      animationController: animationController,
      completer: completer,
      transitionBuilder: transitionBuilder,
      alignment: alignment,
      dismissible: dismissible,
      decorationBuilder: decorationBuilder,
    );
  }

  @override
  String toString() => id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          alignment == other.alignment;

  @override
  int get hashCode => id.hashCode ^ alignment.hashCode;
}

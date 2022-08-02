import 'dart:async';

import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/sliding_animation_widget.dart';

class SheetEntry<T> {
  /// unique value
  final String id;

  /// the wrapped widget
  final SlidingAnimationWidget slidingAnimationWidget;

  /// the sheet's controller
  final AnimationController animationController;

  final AnimatedWidget Function(Widget child, Animation<Offset> position) transitionAnimation;
  final Tween<Offset> tweenTransition;

  /// a unique completer for getting a feature result
  final Completer<T?> completer;

  /// which the side do you want to animate a sheet
  final Alignment alignment;

  SheetEntry({
    required this.id,
    required this.slidingAnimationWidget,
    required this.animationController,
    required this.completer,
    required this.tweenTransition,
    required this.transitionAnimation,
    required this.alignment,
  });

  factory SheetEntry.createNewElement({
    required AnimatedWidget Function(Widget child, Animation<Offset> position) transitionAnimation,
    required Tween<Offset> tweenTransition,
    required TickerProvider tickerProvider,
    required Duration animationDuration,
    required Widget sheet,
    required Completer<T?> completer,
    required Alignment alignment,
    bool initWidthAnimation = true,
  }) {
    final uniqueId = UniqueKey().toString();

    final animationController = AnimationController(
      vsync: tickerProvider,
      duration: animationDuration,
    );

    final animatedSheet = SlidingAnimationWidget(
      key: ValueKey(uniqueId),
      transitionAnimation: transitionAnimation,
      animationController: animationController,
      initWithAnimation: initWidthAnimation,
      tweenTransition: tweenTransition,
      child: sheet,
    );

    return SheetEntry<T>(
      id: uniqueId,
      slidingAnimationWidget: animatedSheet,
      animationController: animationController,
      completer: completer,
      transitionAnimation: transitionAnimation,
      tweenTransition: tweenTransition,
      alignment: alignment,
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

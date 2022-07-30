import 'dart:async';

import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/sliding_animation_widget.dart';

class SideMenuEntry<T> {
  /// unique value
  final String name;

  /// the wrapped widget
  final SlidingAnimationWidget slidingAnimationWidget;

  /// the sideSheet's controller
  final AnimationController animationController;

  /// the sideSheet's width
  final double width;

  /// a unique completer for getting a feature result
  final Completer completer;

  SideMenuEntry({
    required this.name,
    required this.slidingAnimationWidget,
    required this.animationController,
    required this.width,
    required this.completer,
  });

  factory SideMenuEntry.createNewElement({
    required String name,
    required TickerProvider tickerProvider,
    required Duration animationDuration,
    required Widget sideSheet,
    required double width,
    required Completer<T> completer,
    bool initWidthAnimation = true,
  }) {
    final animationController = AnimationController(
      vsync: tickerProvider,
      duration: animationDuration,
    );

    final animatedSideSheet = SlidingAnimationWidget(
      key: ValueKey(name),
      animationController: animationController,
      initWithAnimation: initWidthAnimation,
      sheetWidth: width,
      child: sideSheet,
    );

    return SideMenuEntry(
      name: name,
      slidingAnimationWidget: animatedSideSheet,
      animationController: animationController,
      width: width,
      completer: completer,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SideMenuEntry &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          width == other.width;

  @override
  int get hashCode => name.hashCode ^ width.hashCode;
}

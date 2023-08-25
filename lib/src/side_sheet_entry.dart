import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nested_side_sheet/src/animated_side_sheet.dart';
import 'package:nested_side_sheet/src/side_sheet_host.dart';
import 'package:nested_side_sheet/src/side_sheet_position.dart';

class SideSheetEntry<T> {
  /// Unique identifier of the side sheet in the navigation stack.
  final UniqueKey id;

  /// Last known index of the side sheet in the navigation stack.
  final int index;

  /// Side sheet content.
  final AnimatedSideSheet animatedSideSheet;

  /// Side sheet navigation animation controller.
  final AnimationController animationController;

  /// Side sheet navigation animation custom transition builder.
  final SideSheetTransitionBuilder transitionBuilder;

  /// Unique completer for getting navigation result.
  final Completer<T?> completer;

  /// Controls the side sheet position.
  final SideSheetPosition position;

  /// Controls whether the side sheet can be dismissed by clicking outside.
  final bool dismissible;

  /// A decoration widget builder which helps creating custom design.
  final DecorationBuilder? decorationBuilder;

  final Function? dismissCallback;

  SideSheetEntry({
    required this.id,
    required this.index,
    required this.animatedSideSheet,
    required this.animationController,
    required this.completer,
    required this.transitionBuilder,
    required this.position,
    required this.dismissible,
    required this.decorationBuilder,
    this.dismissCallback,
  });

  factory SideSheetEntry.createNewElement({
    required AnimatedWidget Function(Widget child, Animation<double> animation)
        transitionBuilder,
    required TickerProvider tickerProvider,
    required Duration animationDuration,
    required Duration reverseDuration,
    required Widget sheet,
    required Completer<T?> completer,
    required SideSheetPosition position,
    required DecorationBuilder? decorationBuilder,
    required bool dismissible,
    required int index,
    bool initWithAnimation = true,
    Function? dismissCB,
  }) {
    final key = UniqueKey();

    final animationController = AnimationController(
      vsync: tickerProvider,
      duration: animationDuration,
      reverseDuration: reverseDuration,
    );

    final animatedSheet = AnimatedSideSheet(
      key: key,
      transitionBuilder: transitionBuilder,
      animationController: animationController,
      initWithAnimation: initWithAnimation,
      child: sheet,
    );

    return SideSheetEntry<T>(
      id: key,
      index: index,
      animatedSideSheet: animatedSheet,
      animationController: animationController,
      completer: completer,
      transitionBuilder: transitionBuilder,
      position: position,
      dismissible: dismissible,
      decorationBuilder: decorationBuilder,
      dismissCallback: dismissCB,
    );
  }

  @override
  String toString() => id.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SideSheetEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          index == other.index &&
          position == other.position;

  @override
  int get hashCode => id.hashCode ^ index.hashCode ^ position.hashCode;
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nested_side_sheet/src/animated_side_sheet.dart';
import 'package:nested_side_sheet/src/side_sheet_host.dart';
import 'package:nested_side_sheet/src/nested_alignment.dart';

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

  /// Controls navigation transition animation alignment.
  final NestedAlignment alignment;

  /// Controls whether the side sheet can be dismissed by clicking outside.
  final bool dismissible;

  /// A decoration widget builder which helps creating custom design.
  final DecorationBuilder? decorationBuilder;

  SideSheetEntry({
    required this.id,
    required this.index,
    required this.animatedSideSheet,
    required this.animationController,
    required this.completer,
    required this.transitionBuilder,
    required this.alignment,
    required this.dismissible,
    required this.decorationBuilder,
  });

  factory SideSheetEntry.createNewElement({
    required AnimatedWidget Function(Widget child, Animation<double> animation) transitionBuilder,
    required TickerProvider tickerProvider,
    required Duration animationDuration,
    required Duration reverseDuration,
    required Widget sheet,
    required Completer<T?> completer,
    required NestedAlignment alignment,
    required DecorationBuilder? decorationBuilder,
    required bool dismissible,
    required int index,
    bool initWithAnimation = true,
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
      alignment: alignment,
      dismissible: dismissible,
      decorationBuilder: decorationBuilder,
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
          alignment == other.alignment;

  @override
  int get hashCode => id.hashCode ^ index.hashCode ^ alignment.hashCode;
}

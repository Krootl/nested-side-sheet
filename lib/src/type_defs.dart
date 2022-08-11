import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/sheet_entry.dart';
import 'package:krootl_flutter_side_menu/src/sheet_widget.dart';

/// custom animation transition builder
typedef SheetTransitionBuilder = AnimatedWidget Function(
  Widget child,
  Animation<double> position,
);

/// The decoration builder to paint behind the [child].
typedef DecorationBuilder = Widget Function(Widget child);

/// Signature for the [SheetWidgetState.popUntil] predicate argument.
typedef SheetPredicate = bool Function(SheetEntry<dynamic> sheetEntry);
import 'package:flutter/material.dart';

/// custom animation transition builder
typedef SheetTransitionBuilder = AnimatedWidget Function(
  Widget child,
  Animation<double> position,
);

/// The decoration builder to paint behind the [child].
typedef DecorationBuilder = Widget Function(Widget child);
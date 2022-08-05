import 'package:flutter/material.dart';

/// custom animation transition builder
typedef SheetTransitionBuilder = AnimatedWidget Function(
  Widget child,
  Animation<double> position,
);

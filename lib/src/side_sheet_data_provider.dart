import 'package:flutter/material.dart';
import 'package:nested_side_sheet/src/side_sheet_host.dart';

class InheritedSheetDataProvider extends InheritedWidget {
  final NestedSideSheetState state;

  const InheritedSheetDataProvider({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedSheetDataProvider oldWidget) =>
      oldWidget.state != state;
}

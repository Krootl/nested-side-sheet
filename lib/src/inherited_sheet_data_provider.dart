import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/sheet_widget.dart';

class InheritedSheetDataProvider extends InheritedWidget {
  final SheetWidgetState state;

  const InheritedSheetDataProvider({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedSheetDataProvider oldWidget) => oldWidget.state != state;
}

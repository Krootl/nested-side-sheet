import 'package:flutter/widgets.dart';

enum SideSheetPosition {
  left,
  top,
  bottom,
  right;

  Widget positioned(Key key, Widget child) {
    switch (this) {
      case SideSheetPosition.left:
        return Positioned(key: key, left: 0, top: 0, bottom: 0, child: child);
      case SideSheetPosition.right:
        return Positioned(key: key, right: 0, top: 0, bottom: 0, child: child);
      case SideSheetPosition.top:
        return Positioned(key: key, left: 0, top: 0, right: 0, child: child);
      case SideSheetPosition.bottom:
        return Positioned(key: key, left: 0, bottom: 0, right: 0, child: child);
    }
  }
}

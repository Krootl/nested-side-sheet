import 'package:flutter/widgets.dart';

enum SideSheetAlignment {
  left,
  top,
  bottom,
  right;

  Widget positioned(Key key, Widget child) {
    switch (this) {
      case SideSheetAlignment.left:
        return Positioned(key: key, left: 0, top: 0, bottom: 0, child: child);
      case SideSheetAlignment.right:
        return Positioned(key: key, right: 0, top: 0, bottom: 0, child: child);
      case SideSheetAlignment.top:
        return Positioned(key: key, left: 0, top: 0, right: 0, child: child);
      case SideSheetAlignment.bottom:
        return Positioned(key: key, left: 0, bottom: 0, right: 0, child: child);
    }
  }
}

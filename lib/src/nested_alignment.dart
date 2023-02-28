import 'package:flutter/widgets.dart';

enum NestedAlignment {
  left,
  top,
  bottom,
  right;

  Widget positioned(Key key, Widget child) {
    switch (this) {
      case NestedAlignment.left:
        return Positioned(key: key, left: 0, top: 0, bottom: 0, child: child);
      case NestedAlignment.right:
        return Positioned(key: key, right: 0, top: 0, bottom: 0, child: child);
      case NestedAlignment.top:
        return Positioned(key: key, left: 0, top: 0, right: 0, child: child);
      case NestedAlignment.bottom:
        return Positioned(key: key, left: 0, bottom: 0, right: 0, child: child);
    }
  }
}

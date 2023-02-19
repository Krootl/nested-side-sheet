import 'package:flutter/material.dart';
import 'package:nested_side_sheet/src/side_sheet_host.dart';

SideSheetTransitionBuilder leftSideSheetTransition = (child, animation) => SlideTransition(
      position: animation
          .drive(CurveTween(curve: Curves.easeOutCubic))
          .drive(Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)),
      child: child,
    );

SideSheetTransitionBuilder topSideSheetTransition = (child, animation) => SlideTransition(
      position: animation
          .drive(CurveTween(curve: Curves.easeOutCubic))
          .drive(Tween(begin: const Offset(0, -1), end: Offset.zero)),
      child: child,
    );

SideSheetTransitionBuilder rightSideSheetTransition = (child, animation) => SlideTransition(
      position: animation
          .drive(CurveTween(curve: Curves.easeOutCubic))
          .drive(Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)),
      child: child,
    );

SideSheetTransitionBuilder bottomSideSheetTransition = (child, animation) => SlideTransition(
      position: animation
          .drive(CurveTween(curve: Curves.easeOutCubic))
          .drive(Tween(begin: const Offset(0, 1), end: Offset.zero)),
      child: child,
    );

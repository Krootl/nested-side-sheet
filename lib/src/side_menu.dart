import 'package:flutter/material.dart';

const double _kDefaultAppbarHeight = 64;

class SideMenu extends StatelessWidget {
  final Widget? appbar;
  final double? appbarHeight;
  final Widget body;
  final Widget? bottomBar;

  final BorderRadius? borderRadius;

  const SideMenu({
    Key? key,
    this.appbar,
    this.appbarHeight,
    required this.body,
    this.bottomBar,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Scaffold(
          appBar: appbar != null ? buildAppBar() : null,
          body: body,
          bottomNavigationBar: bottomBar,
        ),
      );

  PreferredSize buildAppBar() => PreferredSize(
        preferredSize: Size(
          double.infinity,
          appbarHeight ?? _kDefaultAppbarHeight,
        ),
        child: appbar!,
      );
}

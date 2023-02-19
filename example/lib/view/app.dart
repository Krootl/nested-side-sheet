import 'package:example/view/color.dart';
import 'package:example/view/theme.dart';
import 'package:example/view/widget/home_card.dart';
import 'package:example/view/widget/sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nested_side_sheet/nested_side_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Nested Side Sheet',
        theme: lightTheme(),
        debugShowCheckedModeBanner: false,
        home: Material(
          color: accentColor,
          // Side sheets will be placed on top of SheetWidget child
          child: NestedSideSheet(
            child: MyHomePage(title: 'Nested Side Sheet'),
          ),
        ),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) => HomeCard(
        shadows: kElevationToShadow[8],
        child: Scaffold(
          body: Stack(
            children: [
              buildInfoCard(),
              ...buildButtons(),
            ],
          ),
        ),
      );

  Widget buildInfoCard() => Center(
        child: Container(
          width: 300,
          height: 150,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: accentColor),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => launchUrl(Uri.https('krootl.com')),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SvgPicture.asset(
                        'krootl_logo.svg',
                        height: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(widget.title, style: Theme.of(context).appBarTheme.titleTextStyle),
              ],
            ),
          ),
        ),
      );

  List<Widget> buildButtons() => [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(right: 300),
            child: FloatingActionButton(
              onPressed: openLeftSheet,
              child: Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 150),
            child: FloatingActionButton(
              onPressed: openTopSheet,
              child: Icon(Icons.arrow_upward_rounded),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(left: 300),
            child: FloatingActionButton(
              onPressed: openRightSheet,
              child: Icon(Icons.arrow_forward_rounded),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 150),
            child: FloatingActionButton(
              onPressed: openBottomSheet,
              child: Icon(Icons.arrow_downward_rounded),
            ),
          ),
        ),
      ];

  void openLeftSheet() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    final result = await NestedSideSheet.of(context).push(
      Sheet(
        size: Size(376, MediaQuery.of(context).size.height),
      ),
      transitionBuilder: leftSideSheetTransition,
      alignment: Alignment.centerLeft,
    );

    if (result is String) showSnackBar(result);
  }

  void openTopSheet() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    final decorationBuilder = (child) => HomeCard(child: child);
    final result = await NestedSideSheet.of(context).push(
      Sheet(
        size: Size(MediaQuery.of(context).size.width, 400),
      ),
      transitionBuilder: topSideSheetTransition,
      alignment: Alignment.topCenter,
      decorationBuilder: decorationBuilder,
    );

    if (result is String) showSnackBar(result);
  }

  void openRightSheet() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    final decorationBuilder = (child) => HomeCard(child: child);
    final result = await NestedSideSheet.of(context).push(
      Sheet(
        size: Size(
          MediaQuery.of(context).size.width * (1 / 3),
          MediaQuery.of(context).size.height,
        ),
      ),
      transitionBuilder: rightSideSheetTransition,
      alignment: Alignment.centerRight,
      decorationBuilder: decorationBuilder,
      dismissible: true,
    );

    if (result is String) showSnackBar(result);
  }

  void openBottomSheet() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    final result = await NestedSideSheet.of(context).push(
      Sheet(
        size: Size(MediaQuery.of(context).size.width, 400),
      ),
      transitionBuilder: bottomSideSheetTransition,
      alignment: Alignment.bottomCenter,
    );

    if (result is String) showSnackBar(result);
  }

  void showSnackBar(String result) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result, textAlign: TextAlign.center),
          width: 300,
          behavior: SnackBarBehavior.floating,
        ),
      );
}

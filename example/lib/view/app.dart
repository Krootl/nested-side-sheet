import 'package:example/view/color.dart';
import 'package:example/view/theme.dart';
import 'package:example/view/widget/home_card.dart';
import 'package:example/view/widget/sheet.dart';
import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/krootl_flutter_sheet.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Nested Side Sheet',
        theme: lightTheme(),
        debugShowCheckedModeBanner: false,
        home: Material(
          color: accentColor,
          child: SheetWidget(
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
        shadows: cardShadow,
        child: Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                infoCard(),
                const SizedBox(height: 32),
                navigateButtons(),
              ],
            ),
          ),
        ),
      );

  Widget infoCard() => Container(
        width: 300,
        height: 100,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: accentColor),
          ),
        ),
        child: Center(
          child: Text(
            'Hello World!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  Widget navigateButtons() => Container(
        width: 300,
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  onPressed: onLeftButton,
                  child: Icon(Icons.arrow_back_rounded),
                ),
                FloatingActionButton(
                  onPressed: onRightButton,
                  child: Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ),
            FloatingActionButton(
              onPressed: onBottomCustomAnimation,
              child: Icon(Icons.arrow_downward_rounded),
            ),
          ],
        ),
      );

  void onLeftButton() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    final alignment = Alignment.centerLeft;
    final transitionBuilder = (child, animation) => SlideTransition(
          position: animation.drive(
            Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero),
          ),
          child: child,
        );

    final result = await SheetWidget.of(context).push(
      Sheet(
        size: Size(376, MediaQuery.of(context).size.height),
        alignment: Alignment.centerLeft,
        transitionBuilder: transitionBuilder,
        decorationBuilder: (sheet) => sheet,
      ),
      alignment: alignment,
      transitionBuilder: transitionBuilder,
      decorationBuilder: (sheet) => sheet,
    );
    if (result is String) showSnackBar(result);
  }

  void onRightButton() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    final decorationBuilder = (child) => HomeCard(child: child);

    final result = await SheetWidget.of(context).pushRight(
      Sheet(
        size: Size(
          MediaQuery.of(context).size.width * (1 / 3),
          MediaQuery.of(context).size.height,
        ),
        alignment: Alignment.centerRight,
        decorationBuilder: decorationBuilder,
        transitionBuilder: (child, animation) => SlideTransition(
          position: animation.drive(
            Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero),
          ),
          child: child,
        ),
      ),
      decorationBuilder: decorationBuilder,
      dismissible: true,
    );
    if (result is String) showSnackBar(result);
  }

  void onBottomCustomAnimation() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    final decorationBuilder = (child) => HomeCard(child: child);

    final sheetTransition = (child, animation) => SlideTransition(
          position: animation
              .drive(CurveTween(curve: Curves.easeOutCubic))
              .drive(Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)),
          child: child,
        );

    final result = await SheetWidget.of(context).push(
      Sheet(
        decorationBuilder: decorationBuilder,
        transitionBuilder: sheetTransition,
        size: Size(MediaQuery.of(context).size.width, 400),
        alignment: Alignment.bottomCenter,
      ),
      decorationBuilder: decorationBuilder,
      transitionBuilder: sheetTransition,
      alignment: Alignment.bottomCenter,
    );

    if (result is String) showSnackBar(result);
  }

  void showSnackBar(String result) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result, textAlign: TextAlign.center),
          width: MediaQuery.of(context).size.width / 6,
          behavior: SnackBarBehavior.floating,
        ),
      );
}

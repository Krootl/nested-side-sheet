import 'package:example/view/widget/home_card.dart';
import 'package:example/view/widget/sheet.dart';
import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/krootl_flutter_sheet.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Sheets Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: SheetWidget(
          parentDecorationBuilder: (child) => HomeCard(child: child),
          child: MyHomePage(title: 'Sheets Menu'),
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
        child: Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          body: Stack(
            children: [
              Center(
                child: Container(
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
                ),
              ),
            ],
          ),
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
        backgroundColor: Colors.white,
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

    final result = await SheetWidget.of(context).pushRight(
      Sheet(
        size: Size(
          MediaQuery.of(context).size.width * (1 / 3),
          MediaQuery.of(context).size.height,
        ),
        backgroundColor: Colors.white,
        alignment: Alignment.centerRight,
        transitionBuilder: (child, animation) => SlideTransition(
          position: animation.drive(
            Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero),
          ),
          child: child,
        ),
      ),
      dismissible: true,
    );
    if (result is String) showSnackBar(result);
  }

  void onBottomCustomAnimation() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    final sheetTransition = (child, animation) => SlideTransition(
          position: animation
              .drive(CurveTween(curve: Curves.easeOutCubic))
              .drive(Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)),
          child: child,
        );

    final result = await SheetWidget.of(context).push(
      Sheet(
        transitionBuilder: sheetTransition,
        size: Size(MediaQuery.of(context).size.width, 400),
        alignment: Alignment.bottomCenter,
        backgroundColor: Colors.white,
      ),
      transitionBuilder: sheetTransition,
      alignment: Alignment.bottomCenter,
    );

    if (result is String) showSnackBar(result);
  }

  void showSnackBar(String result) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          behavior: SnackBarBehavior.floating,
        ),
      );
}

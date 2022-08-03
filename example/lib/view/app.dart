import 'package:example/view/navigate_to.dart';
import 'package:example/view/sheets/first_sheet.dart';
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
        home: const SheetWidget(
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
  String? value;

  String? resultOfClosingAllSheets;

  @override
  Widget build(BuildContext context) => Scaffold(
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
                    if (value != null) ...[
                      Text(value!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                    ],
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
                    if (resultOfClosingAllSheets != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        resultOfClosingAllSheets!,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  void onLeftButton() async {
    final result = await NavigateTo.pushLeft(
      context,
      FirstSheet(
        size: const Size(376, double.infinity),
        alignment: Alignment.centerLeft,
      ),
    );
    setState(() {
      if (result is String) resultOfClosingAllSheets = result;
    });
  }

  /// also, you can set parameter [dismissible] = false, if you want
  /// to prevent closing sheets by tapping on the free space
  void onRightButton() async {
    final result = await SheetWidget.of(context).pushRight(
      FirstSheet(
        size: Size(MediaQuery.of(context).size.width * (2 / 3), double.infinity),
        alignment: Alignment.centerRight,
      ),
      dismissible: false,
    );
    setState(() {
      if (result is String) resultOfClosingAllSheets = result;
    });
  }

  void onBottomCustomAnimation() async {
    final result = await NavigateTo.pushBottom(
      context,
      FirstSheet(
        size: Size(MediaQuery.of(context).size.width, 400),
        alignment: Alignment.bottomCenter,
      ),
    );
    setState(() {
      if (result is String) resultOfClosingAllSheets = result;
    });
  }
}

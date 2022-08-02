import 'package:example/view/custom_sheet.dart';
import 'package:example/view/custom/first_sheet.dart';
import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/krootl_flutter_sheet.dart';

void main() {
  runApp(const MyApp());
}

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
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: FloatingActionButton(
                  onPressed: onLeftButton,
                  child: Icon(Icons.arrow_back_rounded),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  onPressed: onRightButton,
                  child: Icon(Icons.arrow_forward_rounded),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  onPressed: onBottomButton,
                  child: Icon(Icons.arrow_downward_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onLeftButton() async {
    final result = await SheetWidget.of(context).pushLeft(
      FirstSheet(
        size: const Size(376, double.infinity),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  void onRightButton() async {
    final result = await SheetWidget.of(context).pushRight(
      FirstSheet(
        size: Size(MediaQuery.of(context).size.width * (2/3), double.infinity),
        alignment: Alignment.centerRight,
      ),
    );
  }

  void onBottomButton() async {
    final result = await SheetWidget.of(context).pushBottom(
      FirstSheet(
        size: Size(MediaQuery.of(context).size.width, 400),
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}

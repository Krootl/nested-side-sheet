import 'package:example/view/sheets/custom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/krootl_flutter_sheet.dart';

class ThirdSheet extends StatefulWidget {
  final Size size;

  const ThirdSheet({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  State<ThirdSheet> createState() => _ThirdSheetState();
}

class _ThirdSheetState extends State<ThirdSheet> {
  @override
  Widget build(BuildContext context) => CustomSheet(
        size: widget.size,
        backgroundColor: Colors.white,
        value: 'the third sheet',
        trailing: FloatingActionButton.small(
          onPressed: () => SheetWidget.of(context).close(
            'Close all sheets from the third sheet',
          ),
          tooltip: 'Popup from all sheets in the stack',
          child: Icon(Icons.close),
        ),
        bodyContent: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Congratulations, you have gone to the end!'),
          ],
        ),
      );
}

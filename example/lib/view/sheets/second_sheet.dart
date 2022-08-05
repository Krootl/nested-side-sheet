import 'package:example/view/sheets/third_sheet.dart';
import 'package:example/view/sheets/custom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/krootl_flutter_sheet.dart';

class SecondSheet extends StatefulWidget {
  final Size size;
  final Alignment alignment;

  const SecondSheet({
    Key? key,
    required this.size,
    required this.alignment,
  }) : super(key: key);

  @override
  State<SecondSheet> createState() => _SecondSheetState();
}

class _SecondSheetState extends State<SecondSheet> {
  String? textValue;

  @override
  Widget build(BuildContext context) => CustomSheet(
        size: widget.size,
        backgroundColor: Colors.white,
        value: 'the second sheet',
        trailing: FloatingActionButton.small(
          onPressed: () => SheetWidget.of(context).close(
            'Close all sheets from the second sheet',
          ),
          tooltip: 'Popup from all sheets in the stack',
          child: Icon(Icons.close),
        ),
        bodyContent: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have called the second sheet',
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () async {
                final result = await SheetWidget.of(context).pushReplace(
                  ThirdSheet(size: widget.size),
                );
                if (result is String) textValue = result;
              },
              child: Text('Replace to third sheet'),
            ),
            const SizedBox(height: 16),
            if (textValue != null) Text('The result of previous sheet $textValue'),
          ],
        ),
      );
}

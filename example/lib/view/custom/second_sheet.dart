import 'package:example/view/custom/third_sheet.dart';
import 'package:example/view/custom_sheet.dart';
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
                if (result != null) setState(() => textValue = result);
              },
              child: Text('Replace to third sheet'),
            ),
            const SizedBox(height: 16),
            if (textValue != null) Text('The result of previous sheet $textValue'),
          ],
        ),
      );
}

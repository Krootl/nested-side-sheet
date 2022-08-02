import 'package:example/view/custom_sheet.dart';
import 'package:flutter/material.dart';

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
        bodyContent: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Congratulations, you have gone to the end!'),
          ],
        ),
      );
}

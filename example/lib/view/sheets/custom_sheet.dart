import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/krootl_flutter_sheet.dart';

class CustomSheet extends StatelessWidget {
  final Color backgroundColor;
  final String value;
  final Size? size;
  final Function()? onPlusButtonTap;

  final Widget? bodyContent;

  const CustomSheet({
    super.key,
    this.bodyContent,
    required this.backgroundColor,
    required this.value,
    this.size,
    this.onPlusButtonTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size?.width,
        height: size?.height,
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: appBar(context) as AppBar,
          body: Center(child: bodyContent),
          floatingActionButton: onPlusButtonTap == null
              ? null
              : FloatingActionButton.small(
                  tooltip: 'Call the next sheet',
                  onPressed: onPlusButtonTap,
                  child: Icon(Icons.add),
                ),
        ),
      );

  Widget appBar(BuildContext context) => AppBar(
        backgroundColor: Colors.amber,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.small(
              tooltip: 'Popup from the $value',
              onPressed: () => SheetWidget.of(context).pop('You have popped from the $value'),
              child: Icon(Icons.arrow_back_rounded),
            ),
            Text(value),
            if (SheetWidget.of(context).currentSheetLength > 1)
              FloatingActionButton.small(
                onPressed: () => SheetWidget.of(context).close('Close all sheets from $value'),
                tooltip: 'Popup from all sheets in the stack',
                child: Icon(Icons.close),
              ),
          ],
        ),
      );
}

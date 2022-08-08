import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/krootl_flutter_sheet.dart';

class Sheet extends StatelessWidget {
  final Size size;

  final int index;
  final Alignment alignment;

  final SheetTransitionBuilder transitionBuilder;
  final DecorationBuilder? decorationBuilder;

  const Sheet({
    super.key,
    required this.size,
    this.index = 1,
    required this.alignment,
    required this.transitionBuilder,
    this.decorationBuilder,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size.width,
        height: size.height,
        child: Material(
          color: Colors.transparent,
          elevation: 4,
          child: Scaffold(
            appBar: appBar(context) as AppBar,
            body: Center(child: bodyContent(context)),
          ),
        ),
      );

  Widget appBar(BuildContext context) => AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (index > 1)
              TextButton(
                onPressed: SheetWidget.of(context).pop,
                child: Text('BACK'),
              ),
            Text('Menu #$index'),
            TextButton(
              onPressed: () => SheetWidget.of(context).close(
                'The sheets has been closed from the ${index}th sheet',
              ),
              child: Text('CLOSE'),
            ),
          ],
        ),
      );

  Widget bodyContent(BuildContext context) => Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => SheetWidget.of(context).push(
                    _sheet,
                    transitionBuilder: transitionBuilder,
                    decorationBuilder: decorationBuilder,
                    alignment: alignment,
                  ),
                  child: Text('PUSH'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () => SheetWidget.of(context).pushReplace(_sheet),
                  child: Text('REPLACE'),
                ),
              ),
            ),
          ],
        ),
      );

  Widget get _sheet => Sheet(
        decorationBuilder: decorationBuilder,
        transitionBuilder: transitionBuilder,
        size: size,
        index: index + 1,
        alignment: alignment,
      );
}

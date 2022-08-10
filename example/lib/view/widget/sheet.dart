import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/krootl_flutter_sheet.dart';

class Sheet extends StatefulWidget {
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
  State<Sheet> createState() => _SheetState();
}

class _SheetState extends State<Sheet> {
  bool get showBackButton => (SheetWidget.of(context).currentSheetIndex(widget) > 0);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size.width,
        height: widget.size.height,
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
        leading: !showBackButton
            ? const SizedBox.shrink()
            : TextButton(
                onPressed: SheetWidget.of(context).pop,
                child: Text('BACK'),
              ),
        title: Text('Menu #${widget.index}'),
        actions: [
          TextButton(
            onPressed: () => SheetWidget.of(context).close(
              'The sheets has been closed from the ${widget.index}th one',
            ),
            child: Text('CLOSE'),
          ),
        ],
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
                    transitionBuilder: widget.transitionBuilder,
                    decorationBuilder: widget.decorationBuilder,
                    alignment: widget.alignment,
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
                  onPressed: () => SheetWidget.of(context).pushReplace(
                    _sheet,
                    decorationBuilder: widget.decorationBuilder,
                    transitionBuilder: widget.transitionBuilder,
                    alignment: widget.alignment,
                  ),
                  child: Text('REPLACE'),
                ),
              ),
            ),
          ],
        ),
      );

  Widget get _sheet => Sheet(
        decorationBuilder: widget.decorationBuilder,
        transitionBuilder: widget.transitionBuilder,
        size: widget.size,
        index: widget.index + 1,
        alignment: widget.alignment,
      );
}

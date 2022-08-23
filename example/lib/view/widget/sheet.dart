import 'package:flutter/material.dart';
import 'package:nested_side_sheet/nested_side_sheet.dart';

class Sheet extends StatefulWidget {
  final Size size;

  final int index;
  final Alignment alignment;

  final SideSheetTransitionBuilder transitionBuilder;
  final DecorationBuilder? decorationBuilder;

  const Sheet({
    super.key,
    required this.size,
    this.index = 0,
    required this.alignment,
    required this.transitionBuilder,
    this.decorationBuilder,
  });

  @override
  State<Sheet> createState() => _SheetState();
}

class _SheetState extends State<Sheet> {
  bool? showBackButton;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showBackButton ??= NestedSideSheet.of(context).indexOf(widget) > 0;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: Material(
          color: Colors.transparent,
          elevation: 4,
          child: Scaffold(
            appBar: appBar(context),
            body: Center(child: bodyContent(context)),
          ),
        ),
      );

  AppBar appBar(BuildContext context) => AppBar(
        leadingWidth: 100,
        leading: !(showBackButton!)
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: NestedSideSheet.of(context).pop,
                  child: Text('BACK'),
                ),
              ),
        title: Text('Sheet #${widget.index}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 100 - 16,
              child: TextButton(
                onPressed: () => NestedSideSheet.of(context).close(
                  'The sheets has been closed from the ${widget.index}th one',
                ),
                child: Text('CLOSE'),
              ),
            ),
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
                  onPressed: () => NestedSideSheet.of(context).push(
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
                  onPressed: () => NestedSideSheet.of(context).pushReplacement(
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

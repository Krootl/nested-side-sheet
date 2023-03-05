import 'package:flutter/material.dart';
import 'package:nested_side_sheet/nested_side_sheet.dart';

class Sheet extends StatefulWidget {
  final int index;
  final Size size;

  const Sheet({
    super.key,
    this.index = 0,
    required this.size,
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
        child: Scaffold(
          appBar: appBar(context),
          body: Center(child: bodyContent(context)),
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
                  'Result: the latest sheet index = ${widget.index}',
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
                    transitionBuilder:
                        NestedSideSheet.of(context).current.transitionBuilder,
                    alignment: NestedSideSheet.of(context).current.alignment,
                    decorationBuilder:
                        NestedSideSheet.of(context).current.decorationBuilder,
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
                    transitionBuilder:
                        NestedSideSheet.of(context).current.transitionBuilder,
                    alignment: NestedSideSheet.of(context).current.alignment,
                    decorationBuilder:
                        NestedSideSheet.of(context).current.decorationBuilder,
                  ),
                  child: Text('REPLACE'),
                ),
              ),
            ),
          ],
        ),
      );

  Widget get _sheet => Sheet(index: widget.index + 1, size: widget.size);
}

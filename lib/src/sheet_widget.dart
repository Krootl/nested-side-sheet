import 'dart:async';

import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/inherited_sheet_data_provider.dart';
import 'package:krootl_flutter_side_menu/src/sheet_entry.dart';

/// default animation duration of showing/hiding a sheet
const _kBaseSettleDuration = Duration(milliseconds: 250);

class SheetWidget extends StatefulWidget {
  const SheetWidget({
    Key? key,
    required this.child,
    this.settleDuration = _kBaseSettleDuration,
    this.scrimColor = Colors.black45,
    this.decorationWidget,
  }) : super(key: key);

  /// the animation duration of showing/hiding a sheet
  final Duration settleDuration;

  /// a background color of the SheetWidget's overlay
  final Color scrimColor;

  /// wrap your top level widget to the [SheetWidget]
  /// of your widget tree
  final Widget child;

  /// The decoration widget to paint behind the [sheet's stack].
  final Widget Function(Widget child)? decorationWidget;

  static SheetWidgetState of(BuildContext context) {
    final inheritedElement =
        context.dependOnInheritedWidgetOfExactType<InheritedSheetDataProvider>();
    if (inheritedElement?.state != null) {
      return inheritedElement!.state;
    } else {
      throw Exception(
        'Cannot find SheetWidgetState in the context.',
      );
    }
  }

  @override
  State<SheetWidget> createState() => SheetWidgetState();
}

class SheetWidgetState extends State<SheetWidget> with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  OverlayState? _overlayState;

  /// background color
  late AnimationController _scrimAnimationController;
  late Animation<Color?> _scrimColorAnimation;

  /// the list of sideSheets
  final _sheetEntries = <SheetEntry>[];

  @override
  void initState() {
    _scrimAnimationController = AnimationController(
      vsync: this,
      duration: widget.settleDuration,
    );
    _scrimColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.scrimColor,
    ).animate(_scrimAnimationController);
    super.initState();
  }

  int get currentStackLength => _sheetEntries.length;

  /// add a sheet to the stack of widgets from the right side
  Future<T?> pushRight<T extends Object?>(Widget sideSheet) => push<T>(
        sideSheet,
        alignment: Alignment.centerRight,
        transitionAnimation: (child, animation) => SlideTransition(
          position: animation.drive(Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)),
          child: child,
        ),
      );

  /// add a sheet to the stack of widgets with custom transition
  Future<T?> push<T extends Object?>(
    Widget sideSheet, {
    required AnimatedWidget Function(Widget child, Animation<double> position) transitionAnimation,
    required Alignment alignment,
  }) async {
    if (!mounted) return null;
    final completer = Completer<T?>();

    final newEntry = SheetEntry<T?>.createNewElement(
      transitionAnimation: transitionAnimation,
      tickerProvider: this,
      sheet: sideSheet,
      completer: completer,
      animationDuration: widget.settleDuration,
      alignment: alignment,
    );
    _sheetEntries.add(newEntry);

    /// if there is not any overlay, it will be created
    if (_overlayEntry == null) _initOverlay();
    if (_overlayState?.mounted == true) {
      _overlayState?.setState(() {});
    }

    return completer.future;
  }

  /// Close all sheets in the stack
  void close<T extends Object?>([T? result]) async {
    // find the first completer of the sheet stack and make it as completed
    // for returning a value to the initial point of sheets
    final firstCompleter = _sheetEntries.first.completer;

    for (final entry in _sheetEntries.reversed.toList()) {
      if (_sheetEntries.last != entry) _removeClearlySheet(entry);
    }
    if (_overlayState?.mounted == true) {
      _overlayState?.setState(() {});
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _pop<T>(result, firstCompleter);
  }

  void pop<T extends Object?>([T? result]) => _pop<T>(result);

  /// Remove the last sheet of the stack
  void _pop<T extends Object?>([T? result, Completer? completer]) async {
    if (_sheetEntries.isNotEmpty) {
      final sideSheet = _sheetEntries.last;
      sideSheet.animationController.reverse();

      await Future.delayed(widget.settleDuration);
      _removeClearlySheet(sideSheet);
      if (_overlayState?.mounted == true) {
        _overlayState?.setState(() {});
      }
      if (completer != null) {
        completer.complete(result);
      } else {
        sideSheet.completer.complete(result);
      }
    }
    _maybeCloseOverlay();
  }

  /// Replace the last sheet of the stack to the new one
  Future<T?> pushReplace<T extends Object?>(
    Widget sideSheet, {
    Alignment? alignment,
  }) async {
    final oldEntry = _sheetEntries.last;
    final indexOfOldEntry = _sheetEntries.indexOf(oldEntry);
    final oldCompleter = oldEntry.completer as Completer<T?>;

    final newEntry = SheetEntry<T?>.createNewElement(
      tickerProvider: this,
      animationDuration: widget.settleDuration,
      sheet: sideSheet,
      completer: oldCompleter,
      initWidthAnimation: false,
      transitionAnimation: oldEntry.transitionAnimation,
      alignment: alignment ?? oldEntry.alignment,
    );
    _sheetEntries.replaceRange(indexOfOldEntry, indexOfOldEntry + 1, [newEntry]);

    if (_overlayState?.mounted == true) {
      _overlayState?.setState(() {});
    }
    return oldCompleter.future;
  }

  /// if there is the last one of the sheet,
  /// the overlay has to be closed after pop upping the last one
  void _maybeCloseOverlay() async {
    if (_sheetEntries.isEmpty) {
      _scrimAnimationController.reverse();
      await Future.delayed(widget.settleDuration);
      _overlayEntry?.remove();
      _overlayEntry = null;
      _overlayState = null;
    }
  }

  void _initOverlay() {
    _overlayState = Overlay.of(context)
      ?..insert(
        _overlayEntry = _buildOverlayEntry(),
      );
    _scrimAnimationController.forward();
  }

  /// remove sheet's entry with disposing its animation controller
  void _removeClearlySheet(SheetEntry entry) {
    entry.animationController.dispose();
    _sheetEntries.removeWhere((e) => e == entry);
  }

  /// showing an overlay with custom navigation stack
  OverlayEntry _buildOverlayEntry() => OverlayEntry(
        builder: (ctx) => InheritedSheetDataProvider(
          state: this,
          child: AnimatedBuilder(
            animation: _scrimColorAnimation,
            builder: (ctx, child) => Material(
              color: _scrimColorAnimation.value,
              child: child,
            ),
            child: widget.decorationWidget == null
                ? _overlayContent(ctx)
                : widget.decorationWidget!(_overlayContent(ctx)),
          ),
        ),
      );

  Widget _overlayContent(BuildContext context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(onTap: close),
          ),
          ..._sheetEntries.map((e) {
            final ignore = e != _sheetEntries.last;
            return Align(
              alignment: e.alignment,
              child: IgnorePointer(
                ignoring: ignore,
                child: e.slidingAnimationWidget,
              ),
            );
          }),
        ],
      );

  @override
  Widget build(BuildContext context) => InheritedSheetDataProvider(
        state: this,
        child: widget.child,
      );
}

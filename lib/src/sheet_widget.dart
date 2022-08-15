import 'dart:async';

import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/inherited_sheet_data_provider.dart';
import 'package:krootl_flutter_side_menu/src/sheet_entry.dart';
import 'package:krootl_flutter_side_menu/src/type_defs.dart';

/// default animation duration of showing/hiding a sheet
const _kBaseSettleDuration = Duration(milliseconds: 300);

class SheetWidget extends StatefulWidget {
  const SheetWidget({
    Key? key,
    required this.child,
    this.settleDuration = _kBaseSettleDuration,
    this.scrimColor = Colors.black45,
    this.parentDecorationBuilder,
  }) : super(key: key);

  /// the animation duration of showing/hiding a sheet
  final Duration settleDuration;

  /// a background color of the SheetWidget's overlay
  final Color scrimColor;

  /// wrap your top level widget to the [SheetWidget]
  /// of your widget tree for finding [SheetWidgetState] in the widget's tree
  final Widget child;

  /// the custom widget for customizing a background view of the sheets.
  final DecorationBuilder? parentDecorationBuilder;

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

  /// prevent unnecessary touches while there is animating
  bool get _blockTouches => _sheetEntries.any(
        (element) => element.animationController.isAnimating,
      );

  /// a background color
  late AnimationController _scrimAnimationController;
  late Animation<Color?> _scrimColorAnimation;

  /// the list of the sheet entries
  final _sheetEntries = <SheetEntry>[];

  int currentSheetIndex(Widget child) {
    final entriesList = _sheetEntries
        .where((element) => !element.willBeRemoved)
        .map((e) => e.slidingAnimationWidget.child)
        .toList();
    return entriesList.indexOf(child);
  }

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

  /// add a sheet to the stack of widgets from the right side
  Future<T?> pushRight<T extends Object?>(
    Widget sideSheet, {
    bool dismissible = true,
    DecorationBuilder? decorationBuilder,
    Duration? animationDuration,
  }) =>
      push<T>(
        sideSheet,
        alignment: Alignment.centerRight,
        transitionBuilder: (child, animation) => SlideTransition(
          position: animation.drive(
            Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero),
          ),
          child: child,
        ),
        decorationBuilder: decorationBuilder,
        dismissible: dismissible,
        animationDuration: _scrimAnimationController.duration =
            animationDuration ?? widget.settleDuration,
      );

  /// add a sheet to the stack of widgets with custom transition
  Future<T?> push<T extends Object?>(
    Widget sideSheet, {
    required SheetTransitionBuilder transitionBuilder,
    required Alignment alignment,
    DecorationBuilder? decorationBuilder,
    bool dismissible = true,
    Duration? animationDuration,
  }) async {
    if (!mounted) return null;
    final completer = Completer<T?>();

    final newEntry = SheetEntry<T?>.createNewElement(
      transitionBuilder: transitionBuilder,
      tickerProvider: this,
      sheet: sideSheet,
      completer: completer,
      decorationBuilder: decorationBuilder ?? widget.parentDecorationBuilder,
      alignment: alignment,
      dismissible: dismissible,
      animationDuration: _scrimAnimationController.duration =
          animationDuration ?? widget.settleDuration,
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
    assert(
      _sheetEntries.isNotEmpty,
      'Nothing to close. Firstly, you need to add the first sheet by the push method',
    );
    if (_blockTouches) return;

    // find the first completer of the sheet stack and make it as completed
    // for returning a value to the initial point of sheets
    final firstCompleter = _sheetEntries.first.completer;

    for (final entry in _sheetEntries.reversed.toList()) {
      if (_sheetEntries.last != entry) {
        _removeClearlySheet(entry);
      }
    }
    if (_overlayState?.mounted == true) {
      _overlayState?.setState(() {});
    }
    await Future.delayed(const Duration(milliseconds: 17));
    _pop<T>(result, firstCompleter);
  }

  void popUntil<T extends Object?>(SheetPredicate predicate, [T? result]) async {
    if (_blockTouches) return;
    for (final entry in _sheetEntries) {
      if (!predicate(entry)) {
        _pop(result);
      }
    }
  }

  void pop<T extends Object?>([T? result]) => _pop<T>(result);

  /// Remove the last sheet of the stack
  void _pop<T extends Object?>([T? result, Completer? completer]) async {
    assert(
      _sheetEntries.isNotEmpty,
      'Nothing to pop. Firstly, you need to add the first sheet by the push method',
    );
    if (_blockTouches) return;

    if (_sheetEntries.isNotEmpty) {
      final sideSheet = _sheetEntries.last;
      sideSheet.animationController.reverse();

      await Future.delayed(
        _scrimAnimationController.duration ?? widget.settleDuration,
      );
      _removeClearlySheet(sideSheet);

      if (_overlayState?.mounted == true) {
        _overlayState?.setState(() {});
      }
      await _maybeCloseOverlay();

      if (completer != null) {
        completer.complete(result);
      } else {
        sideSheet.completer.complete(result);
      }
    }
  }

  /// Replace the last sheet of the stack to the new one
  Future<T?> pushReplace<T extends Object?>(
    Widget newSheet, {
    Alignment? alignment,
    SheetTransitionBuilder? transitionBuilder,
    DecorationBuilder? decorationBuilder,
    Duration? animationDuration,
  }) async {
    assert(
      _sheetEntries.isNotEmpty,
      'Nothing to replace. Firstly, you need to push a sheet to the stack of widget',
    );

    final oldEntry = _sheetEntries.last;
    final oldCompleter = oldEntry.completer as Completer<T?>;

    oldEntry.willBeRemoved = true;

    final newEntry = SheetEntry<T?>.createNewElement(
      tickerProvider: this,
      decorationBuilder: decorationBuilder ?? oldEntry.decorationBuilder,
      sheet: newSheet,
      completer: oldCompleter,
      transitionBuilder: transitionBuilder ?? oldEntry.transitionBuilder,
      alignment: alignment ?? oldEntry.alignment,
      dismissible: oldEntry.dismissible,
      animationDuration: _scrimAnimationController.duration =
          animationDuration ?? widget.settleDuration,
    );

    if (_overlayState?.mounted == true) {
      // add a new sheet entry
      _sheetEntries.add(newEntry);
      _overlayState?.setState(() {});
    }

    // waiting for the end of the animation of a [slidingAnimationWidget]
    await Future.delayed(
      _scrimAnimationController.duration ?? widget.settleDuration,
    );
    await Future.delayed(const Duration(milliseconds: 100));

    // and remove an old sheetEntry from the stack
    if (_overlayState?.mounted == true) {
      _removeClearlySheet(oldEntry);
      _overlayState?.setState(() {});
    }

    return oldCompleter.future;
  }

  /// if there is the last one of the sheet,
  /// the overlay has to be closed after pop upping the last one
  Future<void> _maybeCloseOverlay() async {
    if (_sheetEntries.isEmpty) {
      _scrimAnimationController.reverse();
      await Future.delayed(
        _scrimAnimationController.duration ?? widget.settleDuration,
      );
      _overlayEntry?.remove();
      _overlayEntry = null;
      _overlayState = null;
    }
    _sheetEntries.clear();
  }

  void _initOverlay() {
    _overlayState = Overlay.of(context)
      ?..insert(
        _overlayEntry = _buildOverlayEntry(),
      );
    _scrimAnimationController.forward();
  }

  /// remove sheet's entry from the stack with disposing its animation controller
  void _removeClearlySheet(SheetEntry entry) {
    entry.animationController.dispose();
    _sheetEntries.removeWhere((e) => e == entry);
  }

  /// showing an overlay with a custom nested navigation
  OverlayEntry _buildOverlayEntry() => OverlayEntry(
        builder: (ctx) => GestureDetector(
          onTap: _sheetEntries.any((e) => !e.dismissible) ? null : close,
          child: RepaintBoundary(
            child: InheritedSheetDataProvider(
              state: this,
              child: AnimatedBuilder(
                animation: _scrimColorAnimation,
                builder: (ctx, child) => Material(
                  color: _scrimColorAnimation.value,
                  child: child,
                ),
                child: RepaintBoundary(
                  child: _overlayContent(),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _overlayContent() => Stack(
        children: [
          ..._sheetEntries.map((e) {
            final ignore = e != _sheetEntries.last;
            final sheet = GestureDetector(
              onTap: () {},
              child: Align(
                alignment: e.alignment,
                child: IgnorePointer(
                  ignoring: ignore,
                  child: RepaintBoundary(
                    child: e.slidingAnimationWidget,
                  ),
                ),
              ),
            );
            return RepaintBoundary(
              child: e.decorationBuilder == null ? sheet : e.decorationBuilder!(sheet),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/inherited_sheet_data_provider.dart';
import 'package:krootl_flutter_side_menu/src/sheet_entry.dart';
import 'package:krootl_flutter_side_menu/src/type_defs.dart';

/// default animation duration of showing/hiding a sheet
const _kBaseSettleDuration = Duration(milliseconds: 267);

class SheetWidget extends StatefulWidget {
  const SheetWidget({
    Key? key,
    required this.child,
    this.settleDuration = _kBaseSettleDuration,
    this.reverseSettleDuration = _kBaseSettleDuration,
    this.scrimColor = Colors.black54,
    this.parentDecorationBuilder,
  }) : super(key: key);

  /// the animation duration of showing a sheet
  final Duration settleDuration;

  /// the animation duration of hiding a sheet
  final Duration reverseSettleDuration;

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
  /// prevent unnecessary touches while there is animating
  bool get _blockTouches => _sheetEntries.any(
        (element) => element.animationController.isAnimating,
      );

  /// a background color
  late AnimationController _scrimAnimationController;
  late Animation<Color?> _scrimColorAnimation;

  /// the list of the sheet entries
  final _sheetEntries = <SheetEntry>[];

  /// notifies about the changing in the sheet's widget tree
  final _sheetStateNotifier = ValueNotifier<int>(0);

  int currentSheetIndex(Widget child) {
    final firstWhereOrNull = _sheetEntries.cast<SheetEntry?>().firstWhere(
          (element) => element?.slidingAnimationWidget.child == child,
          orElse: () => null,
        );
    return firstWhereOrNull?.index ?? 1;
  }

  @override
  void initState() {
    _scrimAnimationController = AnimationController(
      vsync: this,
      duration: widget.settleDuration,
      reverseDuration: widget.reverseSettleDuration,
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
    Duration? reverseAnimationDuration,
  }) async {
    if (!mounted) return null;
    final completer = Completer<T?>();

    final newEntry = SheetEntry<T?>.createNewElement(
      index: _sheetEntries.length - 1,
      transitionBuilder: transitionBuilder,
      tickerProvider: this,
      sheet: sideSheet,
      completer: completer,
      decorationBuilder: decorationBuilder ?? widget.parentDecorationBuilder,
      alignment: alignment,
      dismissible: dismissible,
      animationDuration: _setSettleDuration(animationDuration),
      reverseDuration: _setReverseSettleDuration(reverseAnimationDuration),
    );
    _sheetEntries.add(newEntry);

    _scrimAnimationController.forward();
    _sheetStateNotifier.value = _sheetStateNotifier.value + 1;

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

    _sheetStateNotifier.value = _sheetStateNotifier.value + 1;
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
        _setReverseSettleDuration(sideSheet.animationController.reverseDuration),
      );
      _removeClearlySheet(sideSheet);

      _sheetStateNotifier.value = _sheetStateNotifier.value + 1;
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
    Duration? reverseAnimationDuration,
  }) async {
    assert(
      _sheetEntries.isNotEmpty,
      'Nothing to replace. Firstly, you need to push a sheet to the stack of widget',
    );

    final oldEntry = _sheetEntries.last;
    final oldCompleter = oldEntry.completer as Completer<T?>;

    final newEntry = SheetEntry<T?>.createNewElement(
      tickerProvider: this,
      index: oldEntry.index,
      decorationBuilder: decorationBuilder ?? oldEntry.decorationBuilder,
      sheet: newSheet,
      completer: oldCompleter,
      transitionBuilder: transitionBuilder ?? oldEntry.transitionBuilder,
      alignment: alignment ?? oldEntry.alignment,
      dismissible: oldEntry.dismissible,
      animationDuration: _setSettleDuration(animationDuration),
      reverseDuration: _setReverseSettleDuration(reverseAnimationDuration),
    );

    if (mounted == true) {
      // add a new sheet entry
      _sheetEntries.add(newEntry);
      _sheetStateNotifier.value = _sheetStateNotifier.value + 1;
    }

    // waiting for the end of the animation of a [slidingAnimationWidget]
    await Future.delayed(_scrimAnimationController.duration!);
    await Future.delayed(const Duration(milliseconds: 100));

    // and remove an old sheetEntry from the stack
    if (mounted == true) {
      _removeClearlySheet(oldEntry);
      _sheetStateNotifier.value = _sheetStateNotifier.value + 1;
    }

    return oldCompleter.future;
  }

  /// if there is the last one of the sheet,
  /// the overlay has to be closed after pop upping the last one
  Future<void> _maybeCloseOverlay() async {
    if (_sheetEntries.isEmpty) {
      _scrimAnimationController.reverse();
      await Future.delayed(
        _scrimAnimationController.reverseDuration ?? widget.reverseSettleDuration,
      );

      _sheetStateNotifier.value = 0;
      _setSettleDuration(null);
      _setReverseSettleDuration(null);
    }
  }

  Duration _setSettleDuration(Duration? duration) =>
      _scrimAnimationController.duration = duration ?? widget.settleDuration;

  Duration _setReverseSettleDuration(Duration? duration) =>
      _scrimAnimationController.reverseDuration = duration ?? widget.reverseSettleDuration;

  /// remove sheet's entry from the stack with disposing its animation controller
  void _removeClearlySheet(SheetEntry entry) {
    entry.animationController.dispose();
    _sheetEntries.removeWhere((e) => e == entry);
  }

  @override
  Widget build(BuildContext context) => InheritedSheetDataProvider(
        state: this,
        child: Stack(children: [
          RepaintBoundary(child: widget.child),
          AnimatedBuilder(
            animation: _scrimColorAnimation,
            builder: (ctx, child) => GestureDetector(
              onTap: _sheetEntries.any((e) => !e.dismissible) ? null : close,
              child: Material(
                color: _scrimColorAnimation.value,
                child: _scrimColorAnimation.value == Colors.transparent
                    ? const SizedBox.shrink()
                    : child,
              ),
            ),
            child: _sheetWidgetContent(),
          ),
        ]),
      );

  Widget _sheetWidgetContent() => ValueListenableBuilder<int>(
        valueListenable: _sheetStateNotifier,
        builder: (context, value, child) => Stack(
          children: _sheetEntries.map((e) {
            final ignore = e != _sheetEntries.last;
            final sheet = GestureDetector(
              onTap: () {},
              child: Align(
                alignment: e.alignment,
                child: IgnorePointer(
                  ignoring: ignore,
                  child: e.slidingAnimationWidget,
                ),
              ),
            );
            return RepaintBoundary(
              child: e.decorationBuilder == null ? sheet : e.decorationBuilder!(sheet),
            );
          }).toList(),
        ),
      );
}

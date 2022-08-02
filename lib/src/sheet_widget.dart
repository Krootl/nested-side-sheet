import 'dart:async';

import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/inherited_sheet_data_provider.dart';
import 'package:krootl_flutter_side_menu/src/sheet_entry.dart';

/// default animation duration of showing/hiding a sheet
const _kBaseSettleDuration = Duration(milliseconds: 250);

/// Default animation transition
AnimatedWidget Function(
  Widget child,
  Animation<Offset> position,
) get _kDefaultAnimatedWidget =>
    (child, position) => SlideTransition(position: position, child: child);

final _kDefaultTween = Tween<Offset>(
  begin: const Offset(1, 0),
  end: Offset.zero,
);

class SheetWidget extends StatefulWidget {
  const SheetWidget._({
    Key? key,
    required this.child,
    required this.defaultAlignment,
    required this.settleDuration,
    required this.scrimColor,
    required this.decorationWidget,
    required this.defaultTween,
    required this.defaultAnimatedWidget,
  }) : super(key: key);

  factory SheetWidget({
    required Widget child,
    Alignment defaultAlignment = Alignment.centerRight,
    Tween<Offset>? defaultTween,
    Duration? settleDuration,
    Color scrimColor = Colors.black45,
    Widget Function(Widget child)? decorationWidget,
    AnimatedWidget Function(Widget child, Animation<Offset> position)? defaultAnimatedWidget,
  }) =>
      SheetWidget._(
        defaultAnimatedWidget: defaultAnimatedWidget ?? _kDefaultAnimatedWidget,
        defaultAlignment: defaultAlignment,
        defaultTween: defaultTween ?? _kDefaultTween,
        settleDuration: settleDuration ?? _kBaseSettleDuration,
        decorationWidget: decorationWidget,
        scrimColor: scrimColor,
        child: child,
      );

  final AnimatedWidget Function(Widget child, Animation<Offset> position) defaultAnimatedWidget;

  final Tween<Offset> defaultTween;

  /// which the side do you want to animate a sheet
  /// you can choose another value for specific view in [SheetWidget.of(context).push]
  final Alignment defaultAlignment;

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

  /// add a sheet to the stack of widgets
  Future<T?> push<T>(
    Widget sideSheet, {
    AnimatedWidget Function(Widget child, Animation<Offset> position)? transitionAnimation,
    Tween<Offset>? tweenTransition,
    Alignment? alignment,
  }) async {
    if (!mounted) return null;
    final completer = Completer<T?>();

    transitionAnimation ??= widget.defaultAnimatedWidget;

    final newEntry = SheetEntry<T?>.createNewElement(
      transitionAnimation: transitionAnimation,
      tickerProvider: this,
      sheet: sideSheet,
      completer: completer,
      animationDuration: widget.settleDuration,
      alignment: alignment ?? widget.defaultAlignment,
      tweenTransition: tweenTransition ?? widget.defaultTween,
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
  void close() async {
    for (final entry in _sheetEntries.reversed.toList()) {
      if (_sheetEntries.last != entry) _removeClearlySheet(entry);
    }
    _overlayState?.setState(() {});
    await Future.delayed(const Duration(milliseconds: 18));
    pop();
  }

  /// Remove the last sheet of the stack
  void pop<T>([T? result]) async {
    if (_sheetEntries.isNotEmpty) {
      final sideSheet = _sheetEntries.last;
      sideSheet.animationController.reverse();

      await Future.delayed(widget.settleDuration);
      _removeClearlySheet(sideSheet);
      if (_overlayState?.mounted == true) {
        _overlayState?.setState(() {});
      }
      sideSheet.completer.complete(result);
    }
    _maybeCloseOverlay();
  }

  /// Replace the last sheet of the stack to the new one
  Future<T?> pushReplace<T>(
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
      tweenTransition: oldEntry.tweenTransition,
      alignment: alignment ?? oldEntry.alignment,
    );
    _sheetEntries.replaceRange(indexOfOldEntry, indexOfOldEntry + 1, [newEntry]);

    _overlayState?.setState(() {});
    return oldCompleter.future;
  }

  /// if there is the last one of the sheet,
  /// the overlay has to be closed after pop upping after the last one
  void _maybeCloseOverlay() async {
    if (_sheetEntries.isEmpty) {
      _scrimAnimationController.reverse();
      await Future.delayed(widget.settleDuration);
      _overlayEntry?.remove();
      _overlayEntry = null;
      _overlayState = null;

      for (final entry in _sheetEntries) {
        entry.animationController.dispose();
      }
      _sheetEntries.clear();
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
            child: GestureDetector(onTap: () => close()),
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

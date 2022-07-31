import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:krootl_flutter_side_menu/src/side_sheet_entry.dart';

/// the sideSheet width
const _kDefaultSideSheetWidth = 376.0;

/// default animation duration of show/hide a sideSheet
const _kBaseSettleDuration = Duration(milliseconds: 250);

class KrootlSideMenuWidget extends StatefulWidget {
  const KrootlSideMenuWidget({
    Key? key,
    required this.child,
    this.settleDuration = _kBaseSettleDuration,
    this.scrimColor = Colors.black45,
    this.decorationWidget,
  }) : super(key: key);

  /// the animation duration of show/hide a sideSheet
  final Duration settleDuration;

  final Color scrimColor;

  /// wrap your top level widget to the [KrootlSideMenuWidget]
  /// of your widget tree
  final Widget child;

  /// The decoration widget to paint behind the [child].
  final Widget Function(Widget child)? decorationWidget;

  static KrootlSideMenuWidgetState of(BuildContext context) {
    final inheritedElement =
        context.dependOnInheritedWidgetOfExactType<InheritedSideSheetDataProvider>();
    if (inheritedElement?.state != null) {
      return inheritedElement!.state;
    } else {
      throw Exception(
        'Cannot find KrootlSideMenuWidgetState in the context.',
      );
    }
  }

  @override
  State<KrootlSideMenuWidget> createState() => KrootlSideMenuWidgetState();
}

class KrootlSideMenuWidgetState extends State<KrootlSideMenuWidget> with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  OverlayState? _overlayState;

  /// background color
  late AnimationController _scrimAnimationController;
  late Animation<Color?> _scrimColorAnimation;

  /// the list of sideSheets
  final _sideSheetEntry = <SideMenuEntry>[];

  double get maxSideSheetWidth {
    if (_sideSheetEntry.isEmpty) return 0.0;
    return _sideSheetEntry.map((e) => e.width).reduce(max);
  }

  double _newEntrySheetWidth([double? sheetWidth]) =>
      sheetWidth ?? (maxSideSheetWidth == 0 ? _kDefaultSideSheetWidth : maxSideSheetWidth);

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

  /// add the sideSheet to the stack of widgets
  Future<T?> push<T>(
    String name,
    Widget sideSheet, {
    double? sheetWidth,
  }) async {
    if (!mounted) return null;
    final completer = Completer<T?>();

    final newEntry = SideMenuEntry<T?>.createNewElement(
      name: name,
      tickerProvider: this,
      animationDuration: widget.settleDuration,
      sideSheet: sideSheet,
      width: _newEntrySheetWidth(sheetWidth),
      completer: completer,
    );
    _sideSheetEntry.add(newEntry);

    /// if there is not any overlay, it will be created
    if (_overlayEntry == null) _initOverlay();
    if (_overlayState?.mounted == true) {
      _overlayState?.setState(() {});
    }

    return completer.future;
  }

  /// Remove the top side sheet from the stack
  void pop<T>([T? result]) async {
    if (_sideSheetEntry.isNotEmpty) {
      final sideSheet = _sideSheetEntry.last;
      sideSheet.animationController.reverse();

      await Future.delayed(widget.settleDuration);
      _removeClearlySideSheet(sideSheet);
      if (_overlayState?.mounted == true) {
        _overlayState?.setState(() {});
      }
      sideSheet.completer.complete(result);
    }
    _maybeCloseOverlay();
  }

  Future<T?> pushReplace<T>(
    String oldName,
    String newName,
    Widget sideSheet, {
    double? sheetWidth,
  }) async {
    assert(
      _sideSheetEntry.any((element) => element.name == oldName),
      'there are not exist any sideSheetEntry with the oldName',
    );
    final oldEntry = _sideSheetEntry.firstWhere(
      (element) => element.name == oldName,
    );
    final indexOfOldEntry = _sideSheetEntry.indexOf(oldEntry);
    final oldCompleter = oldEntry.completer as Completer<T?>;

    final newEntry = SideMenuEntry<T?>.createNewElement(
      name: newName,
      tickerProvider: this,
      animationDuration: widget.settleDuration,
      sideSheet: sideSheet,
      width: _newEntrySheetWidth(sheetWidth),
      completer: oldCompleter,
      initWidthAnimation: false,
    );
    _sideSheetEntry.replaceRange(indexOfOldEntry, indexOfOldEntry + 1, [newEntry]);

    _overlayState?.setState(() {});
    return oldCompleter.future;
  }

  /// Close all sideSheets in the stack
  void close() async {
    for (final entry in _sideSheetEntry) {
      if (entry != _sideSheetEntry.last) {
        _removeClearlySideSheet(entry);
      }
    }
    _overlayState?.setState(() {});
    await Future.delayed(const Duration(milliseconds: 200));
    pop();
  }

  void _maybeCloseOverlay() async {
    if (_sideSheetEntry.isEmpty) {
      _scrimAnimationController.reverse();
      await Future.delayed(widget.settleDuration);
      _overlayEntry?.remove();
      _overlayEntry = null;
      _overlayState = null;

      for (final entry in _sideSheetEntry) {
        entry.animationController.dispose();
      }
      _sideSheetEntry.clear();
    }
  }

  void _initOverlay() {
    _overlayState = Overlay.of(context)
      ?..insert(
        _overlayEntry = _buildOverlayEntry(),
      );
    _scrimAnimationController.forward();
  }

  void _removeClearlySideSheet(SideMenuEntry entry) {
    entry.animationController.dispose();
    _sideSheetEntry.remove(entry);
  }

  OverlayEntry _buildOverlayEntry() => OverlayEntry(
        builder: (ctx) => InheritedSideSheetDataProvider(
          state: this,
          child: AnimatedBuilder(
            animation: _scrimColorAnimation,
            builder: (ctx, child) => Material(
              color: _scrimColorAnimation.value,
              child: child,
            ),
            child: widget.decorationWidget == null
                ? _overlayContent()
                : widget.decorationWidget!(_overlayContent()),
          ),
        ),
      );

  Widget _overlayContent() => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(onTap: () => close()),
          ),
          ..._sideSheetEntry.map((e) {
            final ignore = e != _sideSheetEntry.last;
            return Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: ignore,
                child: e.slidingAnimationWidget,
              ),
            );
          }),
        ],
      );

  @override
  Widget build(BuildContext context) => InheritedSideSheetDataProvider(
        state: this,
        child: widget.child,
      );
}

class InheritedSideSheetDataProvider extends InheritedWidget {
  final KrootlSideMenuWidgetState state;

  const InheritedSideSheetDataProvider({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(
    InheritedSideSheetDataProvider oldWidget,
  ) =>
      true;
}

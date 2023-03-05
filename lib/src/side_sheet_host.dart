import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:nested_side_sheet/src/side_sheet_data_provider.dart';
import 'package:nested_side_sheet/src/side_sheet_entry.dart';

/// Creates an [AnimatedWidget] that is used for side sheet navigation animation.
typedef SideSheetTransitionBuilder = AnimatedWidget Function(
  Widget child,
  Animation<double> position,
);

/// Creates a decoration widget which helps creating custom design.
typedef DecorationBuilder = Widget Function(Widget child);

/// Signature for the [NestedSideSheetState.popUntil] predicate argument.
typedef SheetPredicate = bool Function(SideSheetEntry<dynamic> entry);

/// Default animation duration for navigation animation.
const _kBaseSettleDuration = Duration(milliseconds: 267);

class NestedSideSheet extends StatefulWidget {
  const NestedSideSheet({
    Key? key,
    required this.child,
    this.settleDuration = _kBaseSettleDuration,
    this.reverseSettleDuration = _kBaseSettleDuration,
    this.scrimColor = Colors.black54,
    this.decorationBuilder,
  }) : super(key: key);

  /// How long forward navigation animation should last.
  final Duration settleDuration;

  /// How long reverse navigation animation should last.
  final Duration reverseSettleDuration;

  /// The color of the scrim that is applied when the side sheet is open.
  final Color scrimColor;

  /// The main content of the screen. Its widget tree will have an access to [NestedSideSheetState].
  final Widget child;

  /// A decoration widget builder which helps creating custom design.
  final DecorationBuilder? decorationBuilder;

  static NestedSideSheetState of(BuildContext context) {
    final state = context
        .dependOnInheritedWidgetOfExactType<InheritedSheetDataProvider>()
        ?.state;
    if (state != null) {
      return state;
    } else {
      throw Exception('Cannot find SideSheetHostState in the context.');
    }
  }

  @override
  State<NestedSideSheet> createState() => NestedSideSheetState();
}

class NestedSideSheetState extends State<NestedSideSheet>
    with TickerProviderStateMixin {
  /// Prevent unnecessary gestures while animation is active.
  bool get _blockGestures =>
      _sheetEntries.any((e) => e.animationController.isAnimating);

  /// The color of the scrim that is applied when the side sheet is open.
  late AnimationController _scrimAnimationController;
  late Animation<Color?> _scrimColorAnimation;

  /// The list of the side sheet entries.
  final _sheetEntries = <SideSheetEntry>[];

  /// Notifies about any changes in the side sheets widget tree.
  final _sheetStateNotifier = ValueNotifier<int>(0);

  void _notifyStateChange() => _sheetStateNotifier.value += 1;

  int indexOf(Widget sheet) =>
      _sheetEntries
          .firstWhereOrNull((e) => e.animatedSideSheet.child == sheet)
          ?.index ??
      -1;

  SideSheetEntry get current => _sheetEntries.last;

  SideSheetEntry? get currentOrNull => _sheetEntries.lastOrNull;

  @override
  void initState() {
    super.initState();
    _scrimAnimationController = AnimationController(
      vsync: this,
      duration: widget.settleDuration,
      reverseDuration: widget.reverseSettleDuration,
    );
    _scrimColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.scrimColor,
    ).animate(_scrimAnimationController);
  }

  /// Push the given sheet onto the navigation stack.
  Future<T?> push<T extends Object?>(
    Widget sheet, {
    required SideSheetTransitionBuilder transitionBuilder,
    required Alignment alignment,
    DecorationBuilder? decorationBuilder,
    bool dismissible = true,
    Duration? animationDuration,
    Duration? reverseAnimationDuration,
  }) async {
    if (!mounted || _blockGestures) return null;
    final completer = Completer<T?>();

    final newEntry = SideSheetEntry<T?>.createNewElement(
      index: _sheetEntries.length,
      transitionBuilder: transitionBuilder,
      tickerProvider: this,
      sheet: sheet,
      completer: completer,
      decorationBuilder: decorationBuilder ?? widget.decorationBuilder,
      alignment: alignment,
      dismissible: dismissible,
      animationDuration: _setSettleDuration(animationDuration),
      reverseDuration: _setReverseSettleDuration(reverseAnimationDuration),
    );
    _sheetEntries.add(newEntry);
    _notifyStateChange();

    if (_scrimAnimationController.value == 0) {
      _scrimAnimationController.forward();
    }

    return completer.future;
  }

  /// Clears all the sheets from the navigation stack.
  /// Topmost widget is closed with animation and its result is returned.
  void close<T extends Object?>([T? result]) async {
    if (_blockGestures) return;

    if (_sheetEntries.isEmpty) {
      throw StateError('No active sheets to close.');
    }

    // Find the first completer in the navigation stack
    // and use it to return result all the way back.
    final firstCompleter = _sheetEntries.first.completer;

    for (final entry in _sheetEntries.reversed.toList()) {
      if (_sheetEntries.last != entry) {
        _removeSheetSilently(entry);
      }
    }

    _notifyStateChange();
    await Future.delayed(const Duration(milliseconds: 17));
    _pop<T>(result, firstCompleter);
  }

  /// Clears the sheets from the navigation stack until 'predicate' function returns true.
  /// The top-most widget is closed with animation and its result is returned.
  void popUntil<T extends Object?>(
    SheetPredicate predicate, [
    T? result,
  ]) async {
    if (_blockGestures) return;

    if (_sheetEntries.isEmpty) {
      throw StateError('No active sheets to pop.');
    }

    final lastEntry = _sheetEntries.last;
    final candidate = _sheetEntries.cast<SideSheetEntry?>().firstWhere(
          (entry) => entry == null ? false : predicate(entry),
          orElse: () => null,
        );

    // Nothing found, just close all the sheets.
    if (candidate == null) {
      close();
      return;
    }

    // Otherwise, pop until candidate sheet.
    Completer? completer;
    try {
      // Find the candidate index.
      final candidateIndex = _sheetEntries.indexOf(candidate);
      // Find the completer, that was created by the candidate sheet.
      final preCandidate = _sheetEntries[candidateIndex + 1];
      completer = preCandidate.completer;
    } catch (_) {
      /*ignore*/
    }

    for (final entry in _sheetEntries.reversed.toList()) {
      if (entry != candidate && entry != lastEntry) {
        _removeSheetSilently(entry);
      } else if (predicate(entry)) {
        break;
      }
    }
    _notifyStateChange();
    await Future.delayed(const Duration(milliseconds: 17));
    _pop(result, completer);
  }

  /// Pop the top-most sheet off the navigation stack.
  void pop<T extends Object?>([T? result]) => _pop<T>(result);

  /// Pop the top-most sheet off the navigation stack.
  void _pop<T extends Object?>([T? result, Completer? completer]) async {
    if (_blockGestures) return;

    if (_sheetEntries.isEmpty) {
      throw StateError('No active sheets to pop.');
    }

    if (_sheetEntries.isNotEmpty) {
      final sideSheet = _sheetEntries.last;
      sideSheet.animationController.reverse();

      await Future.delayed(
        _setReverseSettleDuration(
          sideSheet.animationController.reverseDuration,
        ),
      );
      _removeSheetSilently(sideSheet);

      _notifyStateChange();
      await _maybeRemoveOverlay();

      if (completer != null) {
        completer.complete(result);
      } else {
        sideSheet.completer.complete(result);
      }
    }
  }

  /// Replace the current sheet of the navigation stack
  /// by pushing the given sheet and then disposing the previous
  /// sheet once the new sheet has finished animating in.
  Future<T?> pushReplacement<T extends Object?>(
    Widget sheet, {
    Alignment? alignment,
    SideSheetTransitionBuilder? transitionBuilder,
    DecorationBuilder? decorationBuilder,
    Duration? animationDuration,
    Duration? reverseAnimationDuration,
  }) async {
    if (!mounted || _blockGestures) return null;

    if (_sheetEntries.isEmpty) {
      throw StateError('No active sheets to replace.');
    }

    final oldEntry = _sheetEntries.last;
    final oldCompleter = oldEntry.completer as Completer<T?>;

    final newEntry = SideSheetEntry<T?>.createNewElement(
      tickerProvider: this,
      index: oldEntry.index,
      decorationBuilder: decorationBuilder ?? oldEntry.decorationBuilder,
      sheet: sheet,
      completer: oldCompleter,
      transitionBuilder: transitionBuilder ?? oldEntry.transitionBuilder,
      alignment: alignment ?? oldEntry.alignment,
      dismissible: oldEntry.dismissible,
      animationDuration: _setSettleDuration(animationDuration),
      reverseDuration: _setReverseSettleDuration(reverseAnimationDuration),
    );

    if (mounted) {
      _sheetEntries.add(newEntry);
      _notifyStateChange();
    }

    // Wait for the end of the sheet navigation animation.
    await Future.delayed(_scrimAnimationController.duration!);
    await Future.delayed(const Duration(milliseconds: 17));

    // Now remove the old sheet entry from the navigation stack.
    if (mounted) {
      _removeSheetSilently(oldEntry);
      _notifyStateChange();
    }

    return oldCompleter.future;
  }

  /// Remove scrim overlay if the navigation stack is empty.
  Future<void> _maybeRemoveOverlay() async {
    if (_sheetEntries.isEmpty) {
      _scrimAnimationController.reverse();
      await Future.delayed(_scrimAnimationController.reverseDuration ??
          widget.reverseSettleDuration);

      _notifyStateChange();
      _setSettleDuration(null);
      _setReverseSettleDuration(null);
    }
  }

  Duration _setSettleDuration(Duration? duration) =>
      _scrimAnimationController.duration = duration ?? widget.settleDuration;

  Duration _setReverseSettleDuration(Duration? duration) =>
      _scrimAnimationController.reverseDuration =
          duration ?? widget.reverseSettleDuration;

  /// Remove sheet entry from the navigation stack while disposing its animation controller.
  void _removeSheetSilently(SideSheetEntry entry) {
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
                child: _scrimAnimationController.value == 0
                    ? const SizedBox.shrink()
                    : const SizedBox.expand(),
              ),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _sheetStateNotifier,
            builder: (context, value, child) => Stack(
              children: _sheetEntries.map((entry) {
                final ignore = entry != _sheetEntries.last;
                final sheet = IgnorePointer(
                  ignoring: ignore,
                  child: entry.animatedSideSheet,
                );
                return Align(
                  key: ValueKey(entry),
                  alignment: entry.alignment,
                  child: entry.decorationBuilder?.call(sheet) ?? sheet,
                );
              }).toList(),
            ),
          )
        ]),
      );
}

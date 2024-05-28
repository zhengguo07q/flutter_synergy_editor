import 'package:flutter/cupertino.dart';

import '../../../main/editor_abstract.dart';
import '../../../main/editor_logic.dart';


class EditorVerticalCaretMovementRun
    extends BidirectionalIterator<TextPosition> {
  EditorVerticalCaretMovementRun(
    this._editor,
    this._currentTextPosition,
  );

  TextPosition _currentTextPosition;

  final AbstractEditorRenderBox _editor;

  @override
  TextPosition get current {
    return _currentTextPosition;
  }

  @override
  bool moveNext() {
    _currentTextPosition = _editor.layoutMetricsPart
        .getTextPositionBelow(_currentTextPosition);
    return true;
  }

  @override
  bool movePrevious() {
    _currentTextPosition = _editor.layoutMetricsPart
        .getTextPositionAbove(_currentTextPosition);
    return true;
  }
}

class UpdateTextSelectionToAdjacentLineAction<
    T extends DirectionalCaretMovementIntent> extends ContextAction<T> {
  UpdateTextSelectionToAdjacentLineAction(this.state);

  final AbstractEditorLogic state;

  EditorVerticalCaretMovementRun? _verticalMovementRun;
  TextSelection? _runSelection;

  void stopCurrentVerticalRunIfSelectionChanges() {
    final runSelection = _runSelection;
    if (runSelection == null) {
      assert(_verticalMovementRun == null);
      return;
    }
    _runSelection = state.textEditingValue.selection;
    final currentSelection = state.widget.textHolder.textSelection;
    final continueCurrentRun = currentSelection.isValid &&
        currentSelection.isCollapsed &&
        currentSelection.baseOffset == runSelection.baseOffset &&
        currentSelection.extentOffset == runSelection.extentOffset;
    if (!continueCurrentRun) {
      _verticalMovementRun = null;
      _runSelection = null;
    }
  }

  @override
  void invoke(T intent, [BuildContext? context]) {
    assert(state.textEditingValue.selection.isValid);

    final collapseSelection =
        intent.collapseSelection || !state.widget.selectionEnabled;
    final value = state.textEditingValue;
    if (!value.selection.isValid) {
      return;
    }

    final currentRun = _verticalMovementRun ??
        state.renderEditor
            .startVerticalCaretMovement(state.renderEditor.selection.extent);

    final shouldMove =
        intent.forward ? currentRun.moveNext() : currentRun.movePrevious();
    final newExtent = shouldMove
        ? currentRun.current
        : (intent.forward
            ? TextPosition(offset: state.textEditingValue.text.length)
            : const TextPosition(offset: 0));
    final newSelection = collapseSelection
        ? TextSelection.fromPosition(newExtent)
        : value.selection.extendTo(newExtent);

    Actions.invoke(
      context!,
      UpdateSelectionIntent(
          value, newSelection, SelectionChangedCause.keyboard),
    );
    if (state.textEditingValue.selection == newSelection) {
      _verticalMovementRun = currentRun;
      _runSelection = newSelection;
    }
  }

  @override
  bool get isActionEnabled => state.textEditingValue.selection.isValid;
}

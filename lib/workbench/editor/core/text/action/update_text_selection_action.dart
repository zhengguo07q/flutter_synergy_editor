import 'package:flutter/cupertino.dart';
import '../../../main/editor_logic.dart';
import '../boundary/text_boundary.dart';

/// 更新选择文本动作
class UpdateTextSelectionAction<T extends DirectionalCaretMovementIntent>
    extends ContextAction<T> {
  UpdateTextSelectionAction(this.editorBlock, this.ignoreNonCollapsedSelection,
      this.getTextBoundariesForIntent);

  final AbstractEditorLogic editorBlock;
  final bool ignoreNonCollapsedSelection;
  final TextBoundary Function(AbstractEditorLogic context, T intent) getTextBoundariesForIntent;

  @override
  Object? invoke(T intent, [BuildContext? context]) {
    final selection = editorBlock.textEditingValue.selection;
    assert(selection.isValid);

    final collapseSelection =
        intent.collapseSelection || !editorBlock.widget.selectionEnabled;
    // Collapse to the logical start/end.
    TextSelection _collapse(TextSelection selection) {
      assert(selection.isValid);
      assert(!selection.isCollapsed);
      return selection.copyWith(
        baseOffset: intent.forward ? selection.end : selection.start,
        extentOffset: intent.forward ? selection.end : selection.start,
      );
    }

    if (!selection.isCollapsed &&
        !ignoreNonCollapsedSelection &&
        collapseSelection) {
      return Actions.invoke(
        context!,
        UpdateSelectionIntent(editorBlock.textEditingValue, _collapse(selection),
            SelectionChangedCause.keyboard),
      );
    }

    final textBoundary = getTextBoundariesForIntent(editorBlock, intent);
    final textBoundarySelection = textBoundary.textEditingValue.selection;
    if (!textBoundarySelection.isValid) {
      return null;
    }
    if (!textBoundarySelection.isCollapsed &&
        !ignoreNonCollapsedSelection &&
        collapseSelection) {
      return Actions.invoke(
        context!,
        UpdateSelectionIntent(editorBlock.textEditingValue,
            _collapse(textBoundarySelection), SelectionChangedCause.keyboard),
      );
    }

    final extent = textBoundarySelection.extent;
    final newExtent = intent.forward
        ? textBoundary.getTrailingTextBoundaryAt(extent)
        : textBoundary.getLeadingTextBoundaryAt(extent);

    final newSelection = collapseSelection
        ? TextSelection.fromPosition(newExtent)
        : textBoundarySelection.extendTo(newExtent);

    // If collapseAtReversal is true and would have an effect, collapse it.
    if (!selection.isCollapsed &&
        intent.collapseAtReversal &&
        (selection.baseOffset < selection.extentOffset !=
            newSelection.baseOffset < newSelection.extentOffset)) {
      return Actions.invoke(
        context!,
        UpdateSelectionIntent(
          editorBlock.textEditingValue,
          TextSelection.fromPosition(selection.base),
          SelectionChangedCause.keyboard,
        ),
      );
    }

    return Actions.invoke(
      context!,
      UpdateSelectionIntent(textBoundary.textEditingValue, newSelection,
          SelectionChangedCause.keyboard),
    );
  }

  @override
  bool get isActionEnabled => editorBlock.textEditingValue.selection.isValid;
}
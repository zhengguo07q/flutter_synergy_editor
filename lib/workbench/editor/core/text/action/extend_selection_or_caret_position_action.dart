import 'package:flutter/cupertino.dart';

import '../../../main/editor_logic.dart';
import '../boundary/text_boundary.dart';

class ExtendSelectionOrCaretPositionAction extends ContextAction<
    ExtendSelectionToNextWordBoundaryOrCaretLocationIntent> {
  ExtendSelectionOrCaretPositionAction(
      this.editorBlock, this.getTextBoundariesForIntent);

  final AbstractEditorLogic editorBlock;
  final TextBoundary Function(
      AbstractEditorLogic context, ExtendSelectionToNextWordBoundaryOrCaretLocationIntent intent)
  getTextBoundariesForIntent;

  @override
  Object? invoke(ExtendSelectionToNextWordBoundaryOrCaretLocationIntent intent,
      [BuildContext? context]) {
    final selection = editorBlock.textEditingValue.selection;
    assert(selection.isValid);

    final textBoundary = getTextBoundariesForIntent(editorBlock, intent);
    final textBoundarySelection = textBoundary.textEditingValue.selection;
    if (!textBoundarySelection.isValid) {
      return null;
    }

    final extent = textBoundarySelection.extent;
    final newExtent = intent.forward
        ? textBoundary.getTrailingTextBoundaryAt(extent)
        : textBoundary.getLeadingTextBoundaryAt(extent);

    final newSelection = (newExtent.offset - textBoundarySelection.baseOffset) *
        (textBoundarySelection.extentOffset -
            textBoundarySelection.baseOffset) <
        0
        ? textBoundarySelection.copyWith(
      extentOffset: textBoundarySelection.baseOffset,
      affinity: textBoundarySelection.extentOffset >
          textBoundarySelection.baseOffset
          ? TextAffinity.downstream
          : TextAffinity.upstream,
    )
        : textBoundarySelection.extendTo(newExtent);

    return Actions.invoke(
      context!,
      UpdateSelectionIntent(textBoundary.textEditingValue, newSelection,
          SelectionChangedCause.keyboard),
    );
  }

  @override
  bool get isActionEnabled =>
      editorBlock.widget.selectionEnabled && editorBlock.textEditingValue.selection.isValid;
}
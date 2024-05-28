import 'package:flutter/cupertino.dart';

import '../../../main/editor_logic.dart';
import '../boundary/character_boundary.dart';
import '../boundary/text_boundary.dart';

/// 删除文本动作，执行带方向的删除文本意图
class DeleteTextAction<T extends DirectionalTextEditingIntent>
    extends ContextAction<T> {
  DeleteTextAction(this.editorBlock, this.getTextBoundariesForIntent);

  final AbstractEditorLogic editorBlock;
  final TextBoundary Function(AbstractEditorLogic state, T intent) getTextBoundariesForIntent;

  TextRange _expandNonCollapsedRange(TextEditingValue value) {
    final TextRange selection = value.selection;
    assert(selection.isValid);
    assert(!selection.isCollapsed);
    final TextBoundary atomicBoundary = CharacterBoundary(value);

    return TextRange(
      start: atomicBoundary
          .getLeadingTextBoundaryAt(TextPosition(offset: selection.start))
          .offset,
      end: atomicBoundary
          .getTrailingTextBoundaryAt(TextPosition(offset: selection.end - 1))
          .offset,
    );
  }

  @override
  Object? invoke(T intent, [BuildContext? context]) {
    final selection = editorBlock.textEditingValue.selection;
    assert(selection.isValid);

    if (!selection.isCollapsed) {
      return Actions.invoke(
        context!,
        ReplaceTextIntent(
            editorBlock.textEditingValue,
            '',
            _expandNonCollapsedRange(editorBlock.textEditingValue),
            SelectionChangedCause.keyboard),
      );
    }

    final textBoundary = getTextBoundariesForIntent(editorBlock, intent);
    if (!textBoundary.textEditingValue.selection.isValid) {
      return null;
    }
    if (!textBoundary.textEditingValue.selection.isCollapsed) {
      return Actions.invoke(
        context!,
        ReplaceTextIntent(
            editorBlock.textEditingValue,
            '',
            _expandNonCollapsedRange(textBoundary.textEditingValue),
            SelectionChangedCause.keyboard),
      );
    }

    return Actions.invoke(
      context!,
      ReplaceTextIntent(
        textBoundary.textEditingValue,
        '',
        textBoundary
            .getTextBoundaryAt(textBoundary.textEditingValue.selection.base),
        SelectionChangedCause.keyboard,
      ),
    );
  }

  @override
  bool get isActionEnabled =>
      !editorBlock.widget.readOnly && editorBlock.textEditingValue.selection.isValid;
}
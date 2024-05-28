import 'package:flutter/widgets.dart';
import '../../main/editor_logic.dart';
import 'boundary/word_boundary.dart';
import 'boundary/document_boundary.dart';
import 'boundary/line_break_boundary.dart';
import 'boundary/mixed_boundary.dart';
import 'boundary/whitespace_boundary.dart';
import 'boundary/collapsed_selection_boundary.dart';
import 'boundary/expanded_text_boundary.dart';
import 'boundary/text_boundary.dart';
import 'boundary/character_boundary.dart';

/// 一个边界构建器
///
/// 通过给定的[Intent] 获取这个所需要的文本边界
class BoundaryBuilder{
  /// 字符字符边界
  static TextBoundary characterBoundary(AbstractEditorLogic editorBlock, DirectionalTextEditingIntent intent) {
    final TextBoundary atomicTextBoundary =
    CharacterBoundary(editorBlock.textEditingValue);
    return CollapsedSelectionBoundary(atomicTextBoundary, intent.forward);
  }

  /// 单词边界
  static TextBoundary nextWordBoundary(AbstractEditorLogic editorBlock, DirectionalTextEditingIntent intent) {
    final TextBoundary atomicTextBoundary;
    final TextBoundary boundary;

    atomicTextBoundary = CharacterBoundary(editorBlock.textEditingValue);
    // 删除单词的时候，需要组合单词判断和空白符判断，删除单词会把之前的空白符号也一起删掉
    boundary = ExpandedTextBoundary(WhitespaceBoundary(editorBlock.textEditingValue),
        WordBoundary(editorBlock.renderEditor.layoutMetricsPart, editorBlock.textEditingValue));

    // 删除方向会影响空白字符的删除模式
    final mixedBoundary = intent.forward
        ? MixedBoundary(atomicTextBoundary, boundary)
        : MixedBoundary(boundary, atomicTextBoundary);
    // 使用[MixedBoundary]来确保删除后不会在字段中留下无效的代码点。
    return CollapsedSelectionBoundary(mixedBoundary, intent.forward);
  }

  /// 行边界
  static TextBoundary linebreak(AbstractEditorLogic editorBlock, DirectionalTextEditingIntent intent) {
    final TextBoundary atomicTextBoundary;
    final TextBoundary boundary;

    atomicTextBoundary = CharacterBoundary(editorBlock.textEditingValue);
    boundary = LineBreakBoundary(editorBlock.renderEditor.layoutMetricsPart, editorBlock.textEditingValue);

    // The _MixedBoundary is to make sure we don't leave invalid code units in
    // the field after deletion.
    // `boundary` doesn't need to be wrapped in a _CollapsedSelectionBoundary,
    // since the document boundary is unique and the linebreak boundary is
    // already caret-location based.
    return intent.forward
        ? MixedBoundary(
        CollapsedSelectionBoundary(atomicTextBoundary, true), boundary)
        : MixedBoundary(
        boundary, CollapsedSelectionBoundary(atomicTextBoundary, false));
  }

  /// 文档边界
  static TextBoundary documentBoundary(AbstractEditorLogic editorBlock, DirectionalTextEditingIntent intent) =>
      DocumentBoundary(editorBlock.textEditingValue);
}
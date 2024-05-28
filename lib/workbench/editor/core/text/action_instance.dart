import 'package:flutter/widgets.dart';

import '../../main/editor_logic.dart';
import 'action/copy_selection_action.dart';
import 'action/delete_text_action.dart';
import 'action/extend_selection_or_caret_position_action.dart';
import 'action/select_all_action.dart';
import 'action/update_text_selection_action.dart';
import 'action/update_text_selection_to_adjacent_line_action.dart';
import 'boundary_builder.dart';

/// 快捷键的动作控制器
///
/// 使用快捷键的时候会触发快捷键逻辑行为
///
/// 目前存在的删除意图有
///   删除字符 DeleteCharacterIntent backspace delete
///   删除一个单词 DeleteToNextWordBoundaryIntent  backspace delete control
///   删除一行  DeleteToLineBreakIntent backspace delete atl
///
///   方向左右 ExtendSelectionByCharacterIntent collapseSelection:true
///   方向上下 ExtendSelectionVerticallyToAdjacentLineIntent collapseSelection:true
///   方向左右单词 ExtendSelectionToNextWordBoundaryIntent collapseSelection: true
///   方向上下单词 ExtendSelectionToLineBreakIntent collapseSelection: true
///   方向左右展开单词 ExtendSelectionToNextWordBoundaryOrCaretLocationIntent collapseSelection: false
///   方向左右行展开单词 ExtendSelectionToLineBreakIntent collapseSelection: false
///   剪切 CopySelectionTextIntent
///   拷贝 CopySelectionTextIntent
///   粘贴 PasteTextIntent
///   全选 SelectAllTextIntent
///
/// 意图是底层固定的。
/// 底层根据配置调用相关意图对应的动作，动作根据一些具体业务逻辑去找相关意图对应的边框函数和定义
/// 得到相关的文本选取后，进行底层基础意图的发布
class ActionInstance  {
  ActionInstance({required AbstractEditorLogic editorBlock})
      : _editorBlock = editorBlock;

  late final AbstractEditorLogic _editorBlock;

  /// 替换文本动作
  late final Action<ReplaceTextIntent> _replaceTextAction =
      CallbackAction<ReplaceTextIntent>(onInvoke: _replaceText);

  /// 更新选择动作
  late final Action<UpdateSelectionIntent> _updateSelectionAction =
      CallbackAction<UpdateSelectionIntent>(onInvoke: _updateSelection);

  /// 调整行动作
  late final UpdateTextSelectionToAdjacentLineAction<
          ExtendSelectionVerticallyToAdjacentLineIntent> _adjacentLineAction =
      UpdateTextSelectionToAdjacentLineAction<
          ExtendSelectionVerticallyToAdjacentLineIntent>(_editorBlock);

  late final Map<Type, Action<Intent>> actions = <Type, Action<Intent>>{
    DoNothingAndStopPropagationTextIntent: DoNothingAction(consumesKey: false),
    ReplaceTextIntent: _replaceTextAction,
    UpdateSelectionIntent: _updateSelectionAction,
    DirectionalFocusIntent: DirectionalFocusAction.forTextField(),

    // 删除文本，删除文本意图执行体，
    DeleteCharacterIntent: _makeOverridable(
        DeleteTextAction<DeleteCharacterIntent>(
            _editorBlock, BoundaryBuilder.characterBoundary)),  // 删除文本
    DeleteToNextWordBoundaryIntent: _makeOverridable(
        DeleteTextAction<DeleteToNextWordBoundaryIntent>(
            _editorBlock, BoundaryBuilder.nextWordBoundary)),
    DeleteToLineBreakIntent: _makeOverridable(
        DeleteTextAction<DeleteToLineBreakIntent>(
            _editorBlock, BoundaryBuilder.linebreak)),

    // 扩展移动或选择
    ExtendSelectionByCharacterIntent: _makeOverridable(
        UpdateTextSelectionAction<ExtendSelectionByCharacterIntent>(
      _editorBlock,
      false,
      BoundaryBuilder.characterBoundary,
    )),
    // 单词
    ExtendSelectionToNextWordBoundaryIntent: _makeOverridable(
        UpdateTextSelectionAction<ExtendSelectionToNextWordBoundaryIntent>(
            _editorBlock, true, BoundaryBuilder.nextWordBoundary)),
    // 行
    ExtendSelectionToLineBreakIntent: _makeOverridable(
        UpdateTextSelectionAction<ExtendSelectionToLineBreakIntent>(
            _editorBlock, true, BoundaryBuilder.linebreak)),
    // 上下选择
    ExtendSelectionVerticallyToAdjacentLineIntent:
        _makeOverridable(_adjacentLineAction),
    // 文档
    ExtendSelectionToDocumentBoundaryIntent: _makeOverridable(
        UpdateTextSelectionAction<ExtendSelectionToDocumentBoundaryIntent>(
            _editorBlock, true, BoundaryBuilder.documentBoundary)),

    // 下一次单词或者光标定位
    ExtendSelectionToNextWordBoundaryOrCaretLocationIntent: _makeOverridable(
        ExtendSelectionOrCaretPositionAction(
            _editorBlock, BoundaryBuilder.nextWordBoundary)),

    // 拷贝粘贴
    SelectAllTextIntent: _makeOverridable(SelectAllAction(_editorBlock)),
    CopySelectionTextIntent:
        _makeOverridable(CopySelectionAction(_editorBlock)),
    PasteTextIntent: _makeOverridable(CallbackAction<PasteTextIntent>(
        onInvoke: (intent) => _editorBlock.pasteText(intent.cause))),
  };

  /// 替换掉原生的快捷键功能
  Action<T> _makeOverridable<T extends Intent>(Action<T> defaultAction) {
    return Action<T>.overridable(
        context: _editorBlock.context, defaultAction: defaultAction);
  }


  /// 更新选择内容
  void _updateSelection(UpdateSelectionIntent intent) {
    _editorBlock.userUpdateTextEditingValue(
      intent.currentTextEditingValue.copyWith(selection: intent.newSelection),
      intent.cause,
    );
  }

  /// 替换文本内容
  void _replaceText(ReplaceTextIntent intent) {
    _editorBlock.userUpdateTextEditingValue(
      intent.currentTextEditingValue
          .replaced(intent.replacementRange, intent.replacementText),
      intent.cause,
    );
  }

}

import 'package:flutter/cupertino.dart';

import '../../../main/editor_logic.dart';


/// 拷贝选择动作
class CopySelectionAction extends ContextAction<CopySelectionTextIntent> {
  CopySelectionAction(this.editorBlock);

  final AbstractEditorLogic editorBlock;

  @override
  void invoke(CopySelectionTextIntent intent, [BuildContext? context]) {
    if (intent.collapseSelection) {
      editorBlock.cutSelection(intent.cause);
    } else {
      editorBlock.copySelection(intent.cause);
    }
  }

  @override
  bool get isActionEnabled =>
      editorBlock.textEditingValue.selection.isValid &&
          !editorBlock.textEditingValue.selection.isCollapsed;
}

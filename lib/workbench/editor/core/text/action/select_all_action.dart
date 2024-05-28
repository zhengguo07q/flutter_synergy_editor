import 'package:flutter/cupertino.dart';

import '../../../main/editor_logic.dart';



class SelectAllAction extends ContextAction<SelectAllTextIntent> {
  SelectAllAction(this.editorBlock);

  final AbstractEditorLogic editorBlock;

  @override
  Object? invoke(SelectAllTextIntent intent, [BuildContext? context]) {
    return Actions.invoke(
      context!,
      UpdateSelectionIntent(
        editorBlock.textEditingValue,
        TextSelection(
            baseOffset: 0, extentOffset: editorBlock.textEditingValue.text.length),
        intent.cause,
      ),
    );
  }

  @override
  bool get isActionEnabled => editorBlock.widget.selectionEnabled;
}
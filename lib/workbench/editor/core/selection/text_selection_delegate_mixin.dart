import 'package:flutter/services.dart';
import 'package:slate/slate.dart';

import '../../embed/embde.dart';
import '../../main/editor_logic.dart';
import '../util/delta_util.dart';

/// 真正去执行动作逻辑的地方
mixin TextSelectionDelegateMixin on AbstractEditorLogic
    implements TextSelectionDelegate {
  // List<Tuple2<int, Style>> get pasteStyle;
  //
  // String get pastePlainText;

  @override
  TextEditingValue get textEditingValue {
    return widget.textHolder.textEditingValue;
  }

  set textEditingValue(TextEditingValue value) {
    final textHolder = widget.textHolder;
    final cursorPosition = value.selection.extentOffset;
    final oldText = textHolder.textEditingValue.text;
    final newText = value.text;
    final diff = DeltaUtil.getDiff(oldText, newText, cursorPosition);
    print(diff);
    if (diff.inserted == '' && diff.deleted == '') {
      return;
    }
    // 提交变更, 一般情况下是插入， 但是当插入和删除都不为null时，说明这个时候一般是取代之前的字符，就是退格删除
    if (diff.deleted.isNotEmpty) {
      TextTransforms.delete(widget.textHolder.document,
          distance: diff.deleted.length, reverse: true);
    }
    TextTransforms.insertText(widget.textHolder.document, diff.inserted);
    final insertedText = _adjustInsertedText(diff.inserted);
//    _applyPasteStyle(insertedText, diff.start);
  }

  // void _applyPasteStyle(String insertedText, int start) {
  //   if (insertedText == pastePlainText && pastePlainText != '') {
  //     final pos = start;
  //     for (var i = 0; i < pasteStyle.length; i++) {
  //       final offset = pasteStyle[i].item1;
  //       final style = pasteStyle[i].item2;
  //       widget.textHolder.formatTextStyle(
  //           pos + offset,
  //           i == pasteStyle.length - 1
  //               ? pastePlainText.length - offset
  //               : pasteStyle[i + 1].item1,
  //           style);
  //     }
  //   }
  // }

  String _adjustInsertedText(String text) {
    // For clip from editor, it may contain image, a.k.a 65532 or '\uFFFC'.
    // For clip from browser, image is directly ignore.
    // Here we skip image when pasting.
    if (!text.codeUnits.contains(Embed.kObjectReplacementInt)) {
      return text;
    }

    final sb = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) == Embed.kObjectReplacementInt) {
        continue;
      }
      sb.write(text[i]);
    }
    return sb.toString();
  }

  @override
  void bringIntoView(TextPosition position) {
    final localRect =
        renderEditor.textPositionPart.getLocalRectForCaret(position);
    // final targetOffset = _getOffsetToRevealCaret(localRect, position);
    //
    // if (scrollController.hasClients) {
    //   scrollController.jumpTo(targetOffset.offset);
    // }
    renderEditor.showOnScreen(rect: localRect);
  }

  // Finds the closest scroll offset to the current scroll offset that fully
  // reveals the given caret rect. If the given rect's main axis extent is too
  // large to be fully revealed in `renderEditable`, it will be centered along
  // the main axis.
  //
  // If this is a multiline EditableText (which means the Editable can only
  // scroll vertically), the given rect's height will first be extended to match
  // `renderEditable.preferredLineHeight`, before the target scroll offset is
  // calculated.
  //  RevealedOffset _getOffsetToRevealCaret(Rect rect, TextPosition position) {
  //    // Make sure scrollController is attached
  //    if (scrollController.hasClients &&
  //        !scrollController.position.allowImplicitScrolling) {
  //      return RevealedOffset(offset: scrollController.offset, rect: rect);
  //    }
  //
  //    final editableSize = renderEditor.size;
  //    final double additionalOffset;
  //    final Offset unitOffset;
  //
  //    // The caret is vertically centered within the line. Expand the caret's
  //    // height so that it spans the line because we're going to ensure that the
  //    // entire expanded caret is scrolled into view.
  //    final expandedRect = Rect.fromCenter(
  //      center: rect.center,
  //      width: rect.width,
  //      height: math.max(rect.height, renderEditor.preferredLineHeight(position)),
  //    );
  //
  //    additionalOffset = expandedRect.height >= editableSize.height
  //        ? editableSize.height / 2 - expandedRect.center.dy
  //        : 0.0
  //        .clamp(expandedRect.bottom - editableSize.height, expandedRect.top);
  //    unitOffset = const Offset(0, 1);
  //
  //    // No overscrolling when encountering tall fonts/scripts that extension past
  //    // the ascent.
  //    var targetOffset = additionalOffset;
  //    if (scrollController.hasClients) {
  //      targetOffset = (additionalOffset + scrollController.offset).clamp(
  //        scrollController.position.minScrollExtent,
  //        scrollController.position.maxScrollExtent,
  //      );
  //    }
  //
  //    final offsetDelta =
  //        (scrollController.hasClients ? scrollController.offset : 0) -
  //            targetOffset;
  //    return RevealedOffset(
  //        rect: rect.shift(unitOffset * offsetDelta), offset: targetOffset);
  // }

  /// 隐藏工具栏
  @override
  void hideToolbar([bool hideHandles = true]) {
    if (selectionController?.toolbar != null) {
      selectionController?.hideToolbar();
    }
  }

  @override
  void userUpdateTextEditingValue(
      TextEditingValue value, SelectionChangedCause cause) {
    textEditingValue = value;
  }

  @override
  bool get cutEnabled => widget.toolbarOptions.cut && !widget.readOnly;

  @override
  bool get copyEnabled => widget.toolbarOptions.copy;

  @override
  bool get pasteEnabled => widget.toolbarOptions.paste && !widget.readOnly;

  @override
  bool get selectAllEnabled => widget.toolbarOptions.selectAll;

  /// Copy current selection to [Clipboard].
  @override
  void copySelection(SelectionChangedCause cause) {
    // widget.controller.copiedImageUrl = null;
    // _pastePlainText = widget.controller.getPlainText();
    // _pasteStyle = widget.controller.getAllIndividualSelectionStyles();
    //
    // final selection = textEditingValue.selection;
    // final part = textEditingValue.part;
    // if (selection.isCollapsed) {
    //   return;
    // }
    // Clipboard.setData(ClipboardData(part: selection.textInside(part)));
    //
    // if (cause == SelectionChangedCause.toolbar) {
    //   bringIntoView(textEditingValue.selection.extent);
    //   // on iOS, Safari does not hide the selection after copy
    //   // however, most other iOS apps do as well as other platforms
    //   // so we'll hide toolbar & selection after copy
    //   hideToolbar(false);
    //
    //   // Collapse the selection and hide the toolbar and handles.
    //   userUpdateTextEditingValue(
    //     TextEditingValue(
    //       part: textEditingValue.part,
    //       selection:
    //       TextSelection.collapsed(offset: textEditingValue.selection.end),
    //     ),
    //     SelectionChangedCause.toolbar,
    //   );
    // }
  }

  @override
  void cutSelection(SelectionChangedCause cause) {
    // widget.controller.copiedImageUrl = null;
    // _pastePlainText = widget.controller.getPlainText();
    // _pasteStyle = widget.controller.getAllIndividualSelectionStyles();
    //
    // if (widget.readOnly) {
    //   return;
    // }
    // final selection = textEditingValue.selection;
    // final part = textEditingValue.part;
    // if (selection.isCollapsed) {
    //   return;
    // }
    // Clipboard.setData(ClipboardData(part: selection.textInside(part)));
    // _replaceText(ReplaceTextIntent(textEditingValue, '', selection, cause));
    //
    // if (cause == SelectionChangedCause.toolbar) {
    //   bringIntoView(textEditingValue.selection.extent);
    //   hideToolbar();
    // }
  }

  /// Paste part from [Clipboard].
  @override
  Future<void> pasteText(SelectionChangedCause cause) async {
    // if (widget.readOnly) {
    //   return;
    // }
    //
    // if (widget.controller.copiedImageUrl != null) {
    //   final index = textEditingValue.selection.baseOffset;
    //   final length = textEditingValue.selection.extentOffset - index;
    //   final copied = widget.controller.copiedImageUrl!;
    //   widget.controller
    //       .replaceText(index, length, BlockEmbed.image(copied.item1), null);
    //   if (copied.item2.isNotEmpty) {
    //     widget.controller.formatText(
    //         getImageNode(widget.controller, index + 1).item1,
    //         1,
    //         StyleAttribute(copied.item2));
    //   }
    //   widget.controller.copiedImageUrl = null;
    //   await Clipboard.setData(const ClipboardData(part: ''));
    //   return;
    // }
    //
    // final selection = textEditingValue.selection;
    // if (!selection.isValid) {
    //   return;
    // }
    // // Snapshot the input before using `await`.
    // // See https://github.com/flutter/flutter/issues/11427
    // final data = await Clipboard.getData(Clipboard.kTextPlain);
    // if (data == null) {
    //   return;
    // }
    //
    // _replaceText(
    //     ReplaceTextIntent(textEditingValue, data.part!, selection, cause));
    //
    // if (cause == SelectionChangedCause.toolbar) {
    //   try {
    //     // ignore exception when paste window is at end of document
    //     bringIntoView(textEditingValue.selection.extent);
    //   } catch (_) {}
    //   hideToolbar();
    // }
  }

  @override
  void selectAll(SelectionChangedCause cause) {
    userUpdateTextEditingValue(
      textEditingValue.copyWith(
        selection: TextSelection(
            baseOffset: 0, extentOffset: textEditingValue.text.length),
      ),
      cause,
    );

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
    }
  }
}

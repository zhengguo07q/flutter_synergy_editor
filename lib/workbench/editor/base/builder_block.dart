import 'package:flutter/widgets.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/editor/base/style/style_default.dart';
import 'package:tuple/tuple.dart';

import '../../updater/text_holder.dart';
import '../core/cursor/cursor_controller.dart';
import 'block/editable_text_block.dart';
import 'line/editable_text_line.dart';
import 'line/text_line.dart';

/// 块构建器
class BuilderBlock {
  static const String line = 'line';
  static const String block = 'block';

  final TextHolder textHolder;
  final Node rootNode;
  final TextDirection textDirection;
  final TextSelection textSelection;
  final Color selectionColor;
  final StyleTextData? styles;
  final bool enableInteractiveSelection;
  final bool hasFocus;
  final CursorController cursorCont;
  final bool readOnly;
  final double devicePixelRatio;

  BuilderBlock({
    required this.textHolder,
    required this.rootNode,
    required this.textDirection,
    required this.textSelection,
    required this.selectionColor,
    required this.styles,
    required this.enableInteractiveSelection,
    required this.hasFocus,
    required this.cursorCont,
    required this.readOnly,
    required this.devicePixelRatio,
  });

  ///构建文本块内内容
  List<Widget> buildChildren() {
    final result = <Widget>[];
    final indentLevelCounts = <int, int>{};
    for (final node in rootNode.children) {
      if (node.type == line) {
        final editableTextLine = getEditableTextLineFromNode(line: node);
        result.add(Directionality(
            textDirection: getDirectionOfNode(node), child: editableTextLine));
      } else if (node.type == block) {
        final attrs = node.attributes;
        final editableTextBlock = EditableTextBlock(
          block: node,
          textHolder: textHolder,
          textDirection: textDirection,
          verticalSpacing: getVerticalSpacingForBlock(node, styles),
          textSelection: textHolder.textSelection,
          color: selectionColor,
          styles: styles,
          enableInteractiveSelection: enableInteractiveSelection,
          hasFocus: hasFocus,
          paddingMinor: attrs.containsKey(AttributeRegister.codeBlock.key)
              ? const EdgeInsets.all(16)
              : null,
          cursorCont: cursorCont,
          indentLevelCounts: indentLevelCounts,
          onCheckboxTap: handleCheckboxTap,
          readOnly: readOnly,
        );
        result.add(Directionality(
            textDirection: getDirectionOfNode(node), child: editableTextBlock));
      } else {
        throw StateError('Unreachable.');
      }
    }
    return result;
  }

  EditableTextLine getEditableTextLineFromNode({
    required Node line,
  }) {
    final textLine = TextLine(
      line: line,
      textDirection: textDirection,
      styles: styles!,
      readOnly: readOnly,
      textHolder: textHolder,
    );
    final editableTextLine = EditableTextLine(
        textHolder: textHolder,
        line: line,
        leading: null,
        body: textLine,
        indentWidth: 0,
        verticalSpacing: getVerticalSpacingForLine(line, styles),
        textDirection: textDirection,
        textSelection: textSelection,
        color: selectionColor,
        enableInteractiveSelection: enableInteractiveSelection,
        hasFocus: hasFocus,
        devicePixelRatio: devicePixelRatio,
        cursorCont: cursorCont);
    return editableTextLine;
  }

  /// 得到行的垂直空间， 上和下
  static Tuple2<double, double> getVerticalSpacingForLine(
      Node line, StyleTextData? defaultStyles) {
    final attrs = line.attributes;
    if (attrs.containsKey(AttributeRegister.header.key)) {
      final int? level = attrs[AttributeRegister.header.key]!.value;
      switch (level) {
        case 1:
          return defaultStyles!.h1!.verticalSpacing;
        case 2:
          return defaultStyles!.h2!.verticalSpacing;
        case 3:
          return defaultStyles!.h3!.verticalSpacing;
        default:
          throw 'Invalid level $level';
      }
    }

    return defaultStyles!.paragraph!.verticalSpacing;
  }

  /// 得到块的垂直空间， 上和下
  Tuple2<double, double> getVerticalSpacingForBlock(
      Node node, StyleTextData? defaultStyles) {
    final attrs = node.attributes;
    if (attrs.containsKey(AttributeRegister.blockQuote.key)) {
      return defaultStyles!.quote!.verticalSpacing;
    } else if (attrs.containsKey(AttributeRegister.codeBlock.key)) {
      return defaultStyles!.code!.verticalSpacing;
    } else if (attrs.containsKey(AttributeRegister.indent.key)) {
      return defaultStyles!.indent!.verticalSpacing;
    } else if (attrs.containsKey(AttributeRegister.list.key)) {
      return defaultStyles!.lists!.verticalSpacing;
    } else if (attrs.containsKey(AttributeRegister.align.key)) {
      return defaultStyles!.align!.verticalSpacing;
    }
    return const Tuple2(0, 0);
  }

  void handleCheckboxTap(int offset, bool value) {
    if (!readOnly) {
      // _disableScrollControllerAnimateOnce = true;
      // final attribute = value ? AttributeRegister.checked : AttributeRegister.unchecked;
      //
      // widget.controller.formatText(offset, 0, attribute);
      //
      // // Checkbox tapping causes controller.selection to go to offset 0
      // // Stop toggling those two toolbar buttons
      // widget.controller.toolbarButtonToggler = {
      //   Attribute.list.key: attribute,
      //   Attribute.header.key: Attribute.header
      // };
      //
      // // Go back from offset 0 to current selection
      // SchedulerBinding.instance!.addPostFrameCallback((_) {
      //   widget.controller.updateSelection(
      //       TextSelection.collapsed(offset: offset), ChangeSource.LOCAL);
      // });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/editor/base/block/render_editable_text_block.dart';
import 'package:tuple/tuple.dart';

import '../../../updater/text_holder.dart';
import '../../core/cursor/cursor_controller.dart';
import '../line/editable_text_line.dart';
import '../line/text_line.dart';
import '../point/point_bullet.dart';
import '../point/point_checkbox.dart';
import '../point/point_number.dart';
import '../style/style_default.dart';
import '../style/style_widget.dart';

class EditableTextBlock extends StatelessWidget {
  const EditableTextBlock(
      {required this.textHolder,
      required this.block,
      required this.textDirection,
      required this.verticalSpacing,
      required this.textSelection,
      required this.color,
      required this.styles,
      required this.enableInteractiveSelection,
      required this.hasFocus,
      required this.paddingMinor,
      required this.cursorCont,
      required this.indentLevelCounts,
      required this.onCheckboxTap,
      required this.readOnly,
      Key? key})
      : super(key: key);

  final TextHolder textHolder;
  final Node block;
  final TextDirection textDirection;
  final Tuple2 verticalSpacing;
  final TextSelection textSelection;
  final Color color;
  final StyleTextData? styles;
  final bool enableInteractiveSelection;
  final bool hasFocus;
  final EdgeInsets? paddingMinor;
  final CursorController cursorCont;
  final Map<int, int> indentLevelCounts;
  final Function(int, bool) onCheckboxTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    final defaultStyles = AttributeStyles.getStyles(context, false);
    return EditableBlock(
        node: block,
        textDirection: textDirection,
        paddingMain: verticalSpacing as Tuple2<double, double>,
        decoration: _getDecorationForBlock(block, defaultStyles) ??
            const BoxDecoration(),
        paddingMinor: paddingMinor,
        children: _buildChildren(context, indentLevelCounts));
  }

  /// 得到块装饰器
  ///
  /// 引号和代码块类型
  BoxDecoration? _getDecorationForBlock(
      Node node, StyleTextData? defaultStyles) {
    final attrs = block.attributes;
    if (attrs.containsKey(AttributeRegister.blockQuote.key)) {
      return defaultStyles!.quote!.decoration;
    }
    if (attrs.containsKey(AttributeRegister.codeBlock.key)) {
      return defaultStyles!.code!.decoration;
    }
    return null;
  }

  List<Widget> _buildChildren(
      BuildContext context, Map<int, int> indentLevelCounts) {
    final defaultStyles = AttributeStyles.getStyles(context, false);
    final count = block.children.length;
    final children = <Widget>[];
    var index = 0;
    for (final line in Iterable.castFrom<dynamic, Node>(block.children)) {
      index++;
      final editableTextLine = EditableTextLine(
          textHolder: textHolder,
          line: line,
          leading:
              _buildLeading(context, line, index, indentLevelCounts, count),
          body: TextLine(
            line: line,
            textDirection: textDirection,
            styles: styles!,
            readOnly: readOnly,
            textHolder: textHolder,
          ),
          indentWidth: _getIndentWidth(),
          verticalSpacing:
              _getSpacingForLine(line, index, count, defaultStyles),
          textDirection: textDirection,
          textSelection: textSelection,
          color: color,
          enableInteractiveSelection: enableInteractiveSelection,
          hasFocus: hasFocus,
          devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
          cursorCont: cursorCont);
      final nodeTextDirection = getDirectionOfNode(line);
      children.add(Directionality(
          textDirection: nodeTextDirection, child: editableTextLine));
    }
    return children.toList(growable: false);
  }

  /// 构建前缀
  Widget? _buildLeading(BuildContext context, Node line, int index,
      Map<int, int> indentLevelCounts, int count) {
    final defaultStyles = AttributeStyles.getStyles(context, false);
    final attrs = line.attributes;
    if (attrs[AttributeRegister.list.key] == AttributeRegister.ol) {
      return PointNumber(
        index: index,
        indentLevelCounts: indentLevelCounts,
        count: count,
        style: defaultStyles!.leading!.style,
        attrs: attrs,
        width: 32,
        padding: 8,
      );
    }

    if (attrs[AttributeRegister.list.key] == AttributeRegister.ul) {
      return PointBullet(
        style:
            defaultStyles!.leading!.style.copyWith(fontWeight: FontWeight.bold),
        width: 32,
      );
    }

    if (attrs[AttributeRegister.list.key] == AttributeRegister.checked) {
      return PointCheckbox(
        size: 14,
        value: true,
        enabled: !readOnly,
        onChanged: (checked) => onCheckboxTap(line.blockOffset, checked),
        uiBuilder: defaultStyles?.lists?.checkboxUIBuilder,
      );
    }

    if (attrs[AttributeRegister.list.key] == AttributeRegister.unchecked) {
      return PointCheckbox(
        size: 14,
        value: false,
        enabled: !readOnly,
        onChanged: (checked) => onCheckboxTap(line.blockOffset, checked),
        uiBuilder: defaultStyles?.lists?.checkboxUIBuilder,
      );
    }

    if (attrs.containsKey(AttributeRegister.codeBlock.key)) {
      return PointNumber(
        index: index,
        indentLevelCounts: indentLevelCounts,
        count: count,
        style: defaultStyles!.code!.style
            .copyWith(color: defaultStyles.code!.style.color!.withOpacity(0.4)),
        width: 32,
        attrs: attrs,
        padding: 16,
        withDot: false,
      );
    }
    return null;
  }

  /// 得到缩进宽
  ///
  /// indent 一个为16像素， blockQuote代码块为16， codeBlock， list为32
  double _getIndentWidth() {
    final attrs = block.attributes;

    final indent = attrs[AttributeRegister.indent.key];
    var extraIndent = 0.0;
    if (indent != null && indent.value != null) {
      extraIndent = 16.0 * indent.value;
    }

    if (attrs.containsKey(AttributeRegister.blockQuote.key)) {
      return 16.0 + extraIndent;
    }

    var baseIndent = 0.0;

    if (attrs.containsKey(AttributeRegister.list.key) ||
        attrs.containsKey(AttributeRegister.codeBlock.key)) {
      baseIndent = 32.0;
    }

    return baseIndent + extraIndent;
  }

  /// 得到行间距
  ///
  /// 行间距分为上下两个
  Tuple2 _getSpacingForLine(
      Node node, int index, int count, StyleTextData? defaultStyles) {
    var top = 0.0, bottom = 0.0;

    final attrs = block.attributes;
    if (attrs.containsKey(AttributeRegister.header.key)) {
      final level = attrs[AttributeRegister.header.key]!.value;
      switch (level) {
        case 1:
          top = defaultStyles!.h1!.verticalSpacing.item1;
          bottom = defaultStyles.h1!.verticalSpacing.item2;
          break;
        case 2:
          top = defaultStyles!.h2!.verticalSpacing.item1;
          bottom = defaultStyles.h2!.verticalSpacing.item2;
          break;
        case 3:
          top = defaultStyles!.h3!.verticalSpacing.item1;
          bottom = defaultStyles.h3!.verticalSpacing.item2;
          break;
        default:
          throw 'Invalid level $level';
      }
    } else {
      late Tuple2 lineSpacing;
      if (attrs.containsKey(AttributeRegister.blockQuote.key)) {
        lineSpacing = defaultStyles!.quote!.lineSpacing;
      } else if (attrs.containsKey(AttributeRegister.indent.key)) {
        lineSpacing = defaultStyles!.indent!.lineSpacing;
      } else if (attrs.containsKey(AttributeRegister.list.key)) {
        lineSpacing = defaultStyles!.lists!.lineSpacing;
      } else if (attrs.containsKey(AttributeRegister.codeBlock.key)) {
        lineSpacing = defaultStyles!.code!.lineSpacing;
      } else if (attrs.containsKey(AttributeRegister.align.key)) {
        lineSpacing = defaultStyles!.align!.lineSpacing;
      } else {
        // 初始化默认值段落行间距
        lineSpacing = defaultStyles!.paragraph!.lineSpacing;
      }
      top = lineSpacing.item1;
      bottom = lineSpacing.item2;
    }

    if (index == 1) {
      top = 0.0;
    }

    if (index == count) {
      bottom = 0.0;
    }

    return Tuple2(top, bottom);
  }
}

TextDirection getDirectionOfNode(Node node) {
  final direction = node.attributes[AttributeRegister.direction.key];
  if (direction == AttributeRegister.rtl) {
    return TextDirection.rtl;
  }
  return TextDirection.ltr;
}

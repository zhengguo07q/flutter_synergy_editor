import 'package:flutter/rendering.dart';
import 'package:slate/slate.dart';

import '../../../../initialize.dart';
import '../../core/box.dart';
import '../../core/editor.dart';
import '../../core/selection/text_selection_util.dart';

/// 块容器的对文字的实现
class RenderBlockContainerBox extends RenderEditableContainerBox
    implements RenderEditableBox {
  RenderBlockContainerBox({
    required Node node,
    List<RenderEditableBox>? children,
    required TextDirection textDirection,
    required Decoration? decoration,
    Decoration? selectedDecoration,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? paddingMain,
    EdgeInsetsGeometry? paddingMinor,
    ImageConfiguration? imageConfiguration,
  }) : super(node: node, children: children) {
    super.initDecoration(
      decoration: decoration,
      selectedDecoration: selectedDecoration,
      imageConfiguration: imageConfiguration,
      textDirection: textDirection,
      margin: margin,
      paddingMain: paddingMain,
      paddingMinor: paddingMinor,
    );
  }

  @override
  TextPosition globalToLocalPosition(TextPosition position) {
    assert(node.containsOffset(position.offset),
        'The provided part position is not in the current node');
    return TextPosition(
      offset: position.offset - node.blockOffset,
      affinity: position.affinity,
    );
  }

  /// 获得行范围
  @override
  TextRange getLineBoundary(TextPosition position) {
    final child = childAtPosition(position);
    final rangeInChild = child.getLineBoundary(TextPosition(
      offset: position.offset - child.node.offset,
      affinity: position.affinity,
    ));
    return TextRange(
      start: rangeInChild.start + child.node.offset,
      end: rangeInChild.end + child.node.offset,
    );
  }

  /// 通过给定的位置，得到偏移
  ///
  ///如果给定的位置原本就不正确
  @override
  Offset getOffsetForCaret(TextPosition position) {
    final child = childAtPosition(position);
    return child.getOffsetForCaret(TextPosition(
          offset: position.offset - child.node.offset,
          affinity: position.affinity,
        )) +
        (child.parentData as BoxParentData).offset;
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    final child = childAtOffset(offset);
    if (child == null) {
      return const TextPosition(offset: -1);
    }
    final parentData = child.parentData as BoxParentData;
    final localPosition =
        child.getPositionForOffset(offset - parentData.offset);
    return TextPosition(
      offset: localPosition.offset + child.node.offset,
      affinity: localPosition.affinity,
    );
  }

  @override
  TextRange getWordBoundary(TextPosition position) {
    final child = childAtPosition(position);
    final nodeOffset = child.node.offset;
    final childWord = child
        .getWordBoundary(TextPosition(offset: position.offset - nodeOffset));
    return TextRange(
      start: childWord.start + nodeOffset,
      end: childWord.end + nodeOffset,
    );
  }

  /// 传入的点位置为它自身在父节点中的位置
  @override
  TextPosition? getPositionAbove(TextPosition position) {
    assert(position.offset < node.length);

    final child = childAtPosition(position);
    final childLocalPosition =
        TextPosition(offset: position.offset - child.node.offset);
    final result = child.getPositionAbove(childLocalPosition);
    if (result != null) {
      return TextPosition(offset: result.offset + child.node.offset);
    }

    final sibling = childBefore(child);
    if (sibling == null) {
      return null;
    }

    final caretOffset = child.getOffsetForCaret(childLocalPosition);
    final testPosition = TextPosition(offset: sibling.node.length - 1);
    final testOffset = sibling.getOffsetForCaret(testPosition);
    final finalOffset = Offset(caretOffset.dx, testOffset.dy);
    return TextPosition(
        offset: sibling.node.offset +
            sibling.getPositionForOffset(finalOffset).offset);
  }

  @override
  TextPosition? getPositionBelow(TextPosition position) {
    assert(position.offset < node.length);

    final child = childAtPosition(position);
    final childLocalPosition =
        TextPosition(offset: position.offset - child.node.offset);
    final result = child.getPositionBelow(childLocalPosition);
    if (result != null) {
      return TextPosition(offset: result.offset + child.node.offset);
    }

    final sibling = childAfter(child);
    if (sibling == null) {
      return null;
    }

    final caretOffset = child.getOffsetForCaret(childLocalPosition);
    final testOffset = sibling.getOffsetForCaret(const TextPosition(offset: 0));
    final finalOffset = Offset(caretOffset.dx, testOffset.dy);
    return TextPosition(
        offset: sibling.node.offset +
            sibling.getPositionForOffset(finalOffset).offset);
  }

  @override
  double preferredLineHeight(TextPosition position) {
    final child = childAtPosition(position);
    return child.preferredLineHeight(
        TextPosition(offset: position.offset - child.node.offset));
  }

  /// 得到基础终结点

  @override
  TextSelectionPoint getBaseEndpointForSelection(TextSelection selection) {
    if (selection.isCollapsed) {
      return TextSelectionPoint(
          Offset(0, preferredLineHeight(selection.extent)) +
              getOffsetForCaret(selection.extent),
          null);
    }

    final baseNode = node.queryChild(selection.start, inclusive: false).node;
    var baseChild = firstChild;
    while (baseChild != null) {
      if (baseChild.node == baseNode) {
        break;
      }
      baseChild = childAfter(baseChild);
    }
    assert(baseChild != null);

    final basePoint = baseChild!.getBaseEndpointForSelection(
        localSelection(baseChild.node, selection, true));
    return TextSelectionPoint(
        basePoint.point + (baseChild.parentData as BoxParentData).offset,
        basePoint.direction);
  }

  @override
  TextSelectionPoint getExtentEndpointForSelection(TextSelection selection) {
    if (selection.isCollapsed) {
      return TextSelectionPoint(
          Offset(0, preferredLineHeight(selection.extent)) +
              getOffsetForCaret(selection.extent),
          null);
    }

    final extentNode = node.queryChild(selection.end, inclusive: false).node;

    var extentChild = firstChild;
    while (extentChild != null) {
      if (extentChild.node == extentNode) {
        break;
      }
      extentChild = childAfter(extentChild);
    }
    assert(extentChild != null);

    final extentPoint = extentChild!.getExtentEndpointForSelection(
        localSelection(extentChild.node, selection, true));
    return TextSelectionPoint(
        extentPoint.point + (extentChild.parentData as BoxParentData).offset,
        extentPoint.direction);
  }

  /// 附加时，会设置选择
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final isBorder =
        SelectionUtil.selectNode(documentControllerInstance.document, node);
    super.defaultPaintDecoration(context, offset, isBorder);
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  Rect getCaretPrototype(TextPosition position) {
    final child = childAtPosition(position);
    final localPosition = TextPosition(
      offset: position.offset - child.node.offset,
      affinity: position.affinity,
    );
    return child.getCaretPrototype(localPosition);
  }

  @override
  Rect getLocalRectForCaret(TextPosition position) {
    final child = childAtPosition(position);
    final localPosition = TextPosition(
      offset: position.offset - child.node.offset,
      affinity: position.affinity,
    );
    final parentData = child.parentData as BoxParentData;
    return child.getLocalRectForCaret(localPosition).shift(parentData.offset);
  }
}

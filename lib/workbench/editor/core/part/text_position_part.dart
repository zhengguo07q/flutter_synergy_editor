import 'dart:math' as math;
import 'dart:ui' as ui show TextBox, BoxHeightStyle, BoxWidthStyle, PlaceholderAlignment, LineMetrics;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../main/editor_abstract.dart';

class TextPositionPart {
  TextPositionPart(this.renderBox);
  AbstractEditorRenderBox renderBox;

  final ValueNotifier<bool> _selectionStartInViewport =
      ValueNotifier<bool>(true);
  ValueListenable<bool> get selectionStartInViewport =>
      _selectionStartInViewport;

  ValueListenable<bool> get selectionEndInViewport => _selectionEndInViewport;
  final ValueNotifier<bool> _selectionEndInViewport = ValueNotifier<bool>(true);

  /// 获取特定位置的行高
  double preferredLineHeight(TextPosition position) {
    final child = renderBox.childAtPosition(position);
    return child.preferredLineHeight(
        TextPosition(offset: position.offset - child.node.offset));
  }

  /// 得到给定本地位置偏移所指定的文本位置
  ///
  /// [offset] 当前点击的全局偏移
  TextPosition getPositionForOffset(Offset offset) {
    final local = renderBox.globalToLocal(offset);
    final child = renderBox.childAtOffset(local);
    if (child == null) {
      return const TextPosition(offset: 0);
    }

    final parentData = child.parentData as BoxParentData;
    final localOffset = local - parentData.offset;
    final localPosition = child.getPositionForOffset(localOffset);
    return TextPosition(
      offset: localPosition.offset + child.node.offset,
      affinity: localPosition.affinity,
    );
  }

  /// 更新显示可见性
  ///
  /// [effectiveOffset] 默认情况是(0, 0)
  void updateSelectionExtentsVisibility(Offset effectiveOffset) {
    final visibleRegion = Offset.zero & renderBox.size;
    final startPosition = TextPosition(
        offset: renderBox.selection.start,
        affinity: renderBox.selection.affinity);
    final startOffset = getOffsetForCaret(startPosition);
    // TODO(justinmc): https://github.com/flutter/flutter/issues/31495
    // Check if the selection is visible with an approximation because a
    // difference between rounded and unrounded values causes the caret to be
    // reported as having a slightly (< 0.5) negative y offset. This rounding
    // happens in paragraph.cc's layout and TextPainer's
    // _applyFloatingPointHack. Ideally, the rounding mismatch will be fixed and
    // this can be changed to be a strict check instead of an approximation.
    const visibleRegionSlop = 0.5;
    _selectionStartInViewport.value = visibleRegion
        .inflate(visibleRegionSlop)
        .contains(startOffset + effectiveOffset);

    final endPosition = TextPosition(
        offset: renderBox.selection.end,
        affinity: renderBox.selection.affinity);
    final endOffset = getOffsetForCaret(endPosition);
    _selectionEndInViewport.value = visibleRegion
        .inflate(visibleRegionSlop)
        .contains(endOffset + effectiveOffset);
  }

  /// 获得这个文本位置位置在编辑器里面的偏移坐标
  Offset getOffsetForCaret(TextPosition position) {
    final child = renderBox.childAtPosition(position);
    final childPosition = child.globalToLocalPosition(position);
    final boxParentData = child.parentData as BoxParentData;
    final localOffsetForCaret = child.getOffsetForCaret(childPosition);
    return boxParentData.offset + localOffsetForCaret;
  }

  Rect getLocalRectForCaret(TextPosition position) {
    final targetChild = renderBox.childAtPosition(position);
    final localPosition = targetChild.globalToLocalPosition(position);

    final childLocalRect = targetChild.getLocalRectForCaret(localPosition);

    final boxParentData = targetChild.parentData as BoxParentData;
    return childLocalRect.shift(Offset(0, boxParentData.offset.dy));
  }

  Rect? getRectForComposingRange(TextRange range) {
    if (!range.isValid || range.isCollapsed) {
      return null;
    }
    return null;
    // _computeTextMetricsIfNeeded();
    //
    // final List<ui.TextBox> boxes = _textPainter.getBoxesForSelection(
    //   TextSelection(baseOffset: range.start, extentOffset: range.end),
    //   boxHeightStyle: selectionHeightStyle,
    //   boxWidthStyle: selectionWidthStyle,
    // );
    //
    // return boxes.fold(
    //   null,
    //       (Rect? accum, TextBox incoming) => accum?.expandToInclude(incoming.toRect()) ?? incoming.toRect(),
    // )?.shift(_paintOffset);
  }
}

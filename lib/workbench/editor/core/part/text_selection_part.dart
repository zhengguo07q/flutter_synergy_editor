import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../main/editor_abstract.dart';
import '../box.dart';
import '../selection/text_selection_util.dart';

/// 事件触发选择位置
class TextSelectionPart {
  TextSelectionPart(this.renderBox);
  AbstractEditorRenderBox renderBox;

  /// 保存最后一个TapDown位置
  Offset? _lastTapDownPosition;

  /// 点击的时候设置位置
  void handleTapDown(TapDownDetails details) {
    _lastTapDownPosition = details.globalPosition;
  }

  /// 处理选择改变
  ///
  /// [nextSelection] 下一个选择的位置
  /// [cause] 选择的方式
  void _handleSelectionChange(
      TextSelection nextSelection, SelectionChangedCause cause) {
    // 没有改变
    final focusingEmpty = nextSelection.baseOffset == 0 &&
        nextSelection.extentOffset == 0 &&
        !renderBox.hasFocus;
    if (nextSelection == renderBox.selection &&
        cause != SelectionChangedCause.keyboard &&
        !focusingEmpty) {
      return;
    }
    renderBox.onSelectionChanged(nextSelection, cause);
  }

  /// 选择单词边缘
  void selectWordEdge(SelectionChangedCause cause) {
    assert(_lastTapDownPosition != null);
    final position =
        renderBox.textPositionPart.getPositionForOffset(_lastTapDownPosition!);
    final child = renderBox.childAtPosition(position);
    final nodeOffset = child.node.offset;
    final localPosition = TextPosition(
        offset: position.offset - nodeOffset, affinity: position.affinity);
    final localWord = child.getWordBoundary(localPosition);
    final word = TextRange(
        start: localWord.start + nodeOffset, end: localWord.end + nodeOffset);
    if (position.offset - word.start <= 1) {
      _handleSelectionChange(
          TextSelection.collapsed(offset: word.start), cause);
    } else {
      _handleSelectionChange(
          TextSelection.collapsed(
              offset: word.end, affinity: TextAffinity.upstream),
          cause);
    }
  }

  /// 选择文本区域 从[from] 到[to]
  void selectPositionAt({
    required Offset from,
    Offset? to,
    required SelectionChangedCause cause,
  }) {
    final textPositionPart = renderBox.textPositionPart;
    final fromPosition = textPositionPart.getPositionForOffset(from);
    final toPosition =
        to == null ? null : textPositionPart.getPositionForOffset(to);

    var baseOffset = fromPosition.offset;
    var extentOffset = fromPosition.offset;
    if (toPosition != null) {
      baseOffset = math.min(fromPosition.offset, toPosition.offset);
      extentOffset = math.max(fromPosition.offset, toPosition.offset);
    }

    final newSelection = TextSelection(
      baseOffset: baseOffset,
      extentOffset: extentOffset,
      affinity: fromPosition.affinity,
    );
    _handleSelectionChange(newSelection, cause);
  }

  /// 设置选择范围
  void selectWordsInRange(
    Offset from,
    Offset? to,
    SelectionChangedCause cause,
  ) {
    final textPositionPart = renderBox.textPositionPart;
    final firstPosition = textPositionPart.getPositionForOffset(from);
    final firstWord = selectWordAtPosition(firstPosition);
    final lastWord = to == null
        ? firstWord
        : selectWordAtPosition(textPositionPart.getPositionForOffset(to));

    _handleSelectionChange(
        TextSelection(
            baseOffset: firstWord.base.offset,
            extentOffset: lastWord.extent.offset,
            affinity: firstWord.affinity),
        cause);
  }

  void selectWord(SelectionChangedCause cause) {
    selectWordsInRange(_lastTapDownPosition!, null, cause);
  }

  /// 设置选择位置
  void selectPosition(SelectionChangedCause cause) {
    selectPositionAt(from: _lastTapDownPosition!, cause: cause);
  }

  TextSelection selectWordAtPosition(TextPosition position) {
    final child = renderBox.childAtPosition(position);
    final nodeOffset = child.node.offset;
    final localPosition = TextPosition(
        offset: position.offset - nodeOffset, affinity: position.affinity);
    final localWord = child.getWordBoundary(localPosition);
    final word = TextRange(
      start: localWord.start + nodeOffset,
      end: localWord.end + nodeOffset,
    );
    if (position.offset >= word.end) {
      return TextSelection.fromPosition(position);
    }
    return TextSelection(baseOffset: word.start, extentOffset: word.end);
  }

  TextSelection selectLineAtPosition(TextPosition position) {
    final child = renderBox.childAtPosition(position);
    final nodeOffset = child.node.offset;
    final localPosition = TextPosition(
        offset: position.offset - nodeOffset, affinity: position.affinity);
    final localLineRange = child.getLineBoundary(localPosition);
    final line = TextRange(
      start: localLineRange.start + nodeOffset,
      end: localLineRange.end + nodeOffset,
    );

    if (position.offset >= line.end) {
      return TextSelection.fromPosition(position);
    }
    return TextSelection(baseOffset: line.start, extentOffset: line.end);
  }

  /// 获得文本选择区域在文本选择中所占据的开始点和结束点
  List<TextSelectionPoint> getEndpointsForSelection(
      TextSelection textSelection) {
    if (textSelection.isCollapsed) {
      final child = renderBox.childAtPosition(textSelection.extent);
      final localPosition =
          TextPosition(offset: textSelection.extentOffset - child.node.offset);
      final localOffset = child.getOffsetForCaret(localPosition);
      final parentData = child.parentData as BoxParentData;
      return <TextSelectionPoint>[
        TextSelectionPoint(
            Offset(0, child.preferredLineHeight(localPosition)) +
                localOffset +
                parentData.offset,
            null)
      ];
    }

    final baseNode =
        renderBox.node.queryChild(textSelection.start, inclusive: true).node;
    var baseChild = renderBox.firstChild;
    while (baseChild != null) {
      if (baseChild.node == baseNode) {
        break;
      }
      baseChild = renderBox.childAfter(baseChild);
    }
    assert(baseChild != null);

    final baseParentData = baseChild!.parentData as BoxParentData;
    final baseSelection = localSelection(baseChild.node, textSelection, true);
    var basePoint = baseChild.getBaseEndpointForSelection(baseSelection);
    basePoint = TextSelectionPoint(
        basePoint.point + baseParentData.offset, basePoint.direction);

    final extentNode =
        renderBox.node.queryChild(textSelection.end, inclusive: true).node;
    RenderEditableBox? extentChild = baseChild;
    while (extentChild != null) {
      if (extentChild.node == extentNode) {
        break;
      }
      extentChild = renderBox.childAfter(extentChild);
    }
    assert(extentChild != null);

    final extentParentData = extentChild!.parentData as BoxParentData;
    final extentSelection =
        localSelection(extentChild.node, textSelection, true);
    var extentPoint =
        extentChild.getExtentEndpointForSelection(extentSelection);
    extentPoint = TextSelectionPoint(
        extentPoint.point + extentParentData.offset, extentPoint.direction);

    return <TextSelectionPoint>[basePoint, extentPoint];
  }
}

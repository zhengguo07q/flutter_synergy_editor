import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../../main/editor_abstract.dart';


class TextLayoutMetricsPart implements TextLayoutMetrics{
  TextLayoutMetricsPart(this.renderBox);
  AbstractEditorRenderBox renderBox;


  @override
  TextSelection getLineAtOffset(TextPosition position) {
    final child = renderBox.childAtPosition(position);
    final nodeOffset = child.node.offset;
    final localPosition = TextPosition(
        offset: position.offset - nodeOffset, affinity: position.affinity);
    final localLineRange = child.getLineBoundary(localPosition);
    final line = TextRange(
      start: localLineRange.start + nodeOffset,
      end: localLineRange.end + nodeOffset,
    );
    return TextSelection(baseOffset: line.start, extentOffset: line.end);
  }

  /// 得到一个行边
  @override
  TextRange getWordBoundary(TextPosition position) {
    final child = renderBox.childAtPosition(position);
    final nodeOffset = child.node.offset;
    final localPosition = TextPosition(
        offset: position.offset - nodeOffset, affinity: position.affinity);
    final localWord = child.getWordBoundary(localPosition);
    return TextRange(
      start: localWord.start + nodeOffset,
      end: localWord.end + nodeOffset,
    );
  }

  /// 返回给定偏移量以上的TextPosition到文本。
  ///
  /// 如果偏移量已经在第一行，则返回第一个字符的偏移量。
  @override
  TextPosition getTextPositionAbove(TextPosition position) {
    final child = renderBox.childAtPosition(position);
    final localPosition =
    TextPosition(offset: position.offset - child.node.blockOffset);

    var newPosition = child.getPositionAbove(localPosition);

    if (newPosition == null) {
      // There was no part above in the current child, check the direct
      // sibling.
      final sibling = renderBox.childBefore(child);
      if (sibling == null) {
        // reached beginning of the document, move to the
        // first character
        newPosition = const TextPosition(offset: 0);
      } else {
        final caretOffset = child.getOffsetForCaret(localPosition);
        final testPosition = TextPosition(offset: sibling.node.length - 1);
        final testOffset = sibling.getOffsetForCaret(testPosition);
        final finalOffset = Offset(caretOffset.dx, testOffset.dy);
        final siblingPosition = sibling.getPositionForOffset(finalOffset);
        newPosition = TextPosition(
            offset: sibling.node.blockOffset + siblingPosition.offset);
      }
    } else {
      newPosition = TextPosition(
          offset: child.node.blockOffset + newPosition.offset);
    }
    return newPosition;
  }

  /// 返回TextPosition下面的给定偏移量到文本。
  ///
  /// 如果偏移量已经在最后一行，则返回最后一个字符的偏移量。
  @override
  TextPosition getTextPositionBelow(TextPosition position) {
    final child = renderBox.childAtPosition(position);
    final localPosition =
    TextPosition(offset: position.offset - child.node.blockOffset);

    var newPosition = child.getPositionBelow(localPosition);

    if (newPosition == null) {
      // There was no part above in the current child, check the direct
      // sibling.
      final sibling = renderBox.childAfter(child);
      if (sibling == null) {
        // reached beginning of the document, move to the
        // last character
        newPosition = TextPosition(offset: renderBox.node.length - 1);
      } else {
        final caretOffset = child.getOffsetForCaret(localPosition);
        const testPosition = TextPosition(offset: 0);
        final testOffset = sibling.getOffsetForCaret(testPosition);
        final finalOffset = Offset(caretOffset.dx, testOffset.dy);
        final siblingPosition = sibling.getPositionForOffset(finalOffset);
        newPosition = TextPosition(
            offset: sibling.node.blockOffset + siblingPosition.offset);
      }
    } else {
      newPosition = TextPosition(
          offset: child.node.blockOffset + newPosition.offset);
    }
    return newPosition;
  }
}
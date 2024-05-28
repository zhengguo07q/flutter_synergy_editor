import 'package:flutter/cupertino.dart';

import 'text_boundary.dart';

/// 强制[innerTextBoundary]解释输入[TextPosition]为插入符号位置而不是代码单元位置。

/// [innerTextBoundary]必须是一个[TextBoundary]来解释输入
/// [TextPosition]作为代码单元位置。
class CollapsedSelectionBoundary extends TextBoundary {
  CollapsedSelectionBoundary(this.innerTextBoundary, this.isForward);

  final TextBoundary innerTextBoundary;
  final bool isForward;

  @override
  TextEditingValue get textEditingValue => innerTextBoundary.textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    return isForward
        ? innerTextBoundary.getLeadingTextBoundaryAt(position)
        : position.offset <= 0
            ? const TextPosition(offset: 0)
            : innerTextBoundary.getLeadingTextBoundaryAt(
                TextPosition(offset: position.offset - 1));
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return isForward
        ? innerTextBoundary.getTrailingTextBoundaryAt(position)
        : position.offset <= 0
            ? const TextPosition(offset: 0)
            : innerTextBoundary.getTrailingTextBoundaryAt(
                TextPosition(offset: position.offset - 1));
  }
}

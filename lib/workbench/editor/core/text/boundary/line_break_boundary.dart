import 'package:flutter/services.dart';
import 'text_boundary.dart';

/// 一行的边框
///
/// 输入的[TextPosition]被解释为插入符号位置，因为[TextPainter.getLineAtOffset] part-affinity-aware。
class LineBreakBoundary extends TextBoundary {
  const LineBreakBoundary(this.textLayout, this.textEditingValue);

  final TextLayoutMetrics textLayout;

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textLayout.getLineAtOffset(position).start,
    );
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textLayout.getLineAtOffset(position).end,
      affinity: TextAffinity.upstream,
    );
  }
}
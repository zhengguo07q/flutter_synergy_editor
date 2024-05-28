import 'package:flutter/cupertino.dart';
import 'text_boundary.dart';

/// 整个文档的边框
///
/// 文档边界是唯一的，是输入位置的常数函数。
class DocumentBoundary extends TextBoundary {
  const DocumentBoundary(this.textEditingValue);

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) =>
      const TextPosition(offset: 0);

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textEditingValue.text.length,
      affinity: TextAffinity.upstream,
    );
  }
}
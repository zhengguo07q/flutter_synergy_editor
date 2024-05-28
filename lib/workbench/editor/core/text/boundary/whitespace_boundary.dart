import 'package:flutter/services.dart';
import 'text_boundary.dart';

/// 对空白符号的删除操作， 当处于单词删除的时候，空白符可以随单词一起删除
///
/// 单词修饰符通常删除空白(和换行)周围的单词边界，
/// IOW空白和一些其他标点符号被认为是搜索方向的下一个单词的一部分。
class WhitespaceBoundary extends TextBoundary {
  const WhitespaceBoundary(this.textEditingValue);

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    for (var index = position.offset; index >= 0; index -= 1) {
      // 判断是否为空白字符
      if (!TextLayoutMetrics.isWhitespace(
          textEditingValue.text.codeUnitAt(index))) {
        return TextPosition(offset: index);
      }
    }
    return const TextPosition(offset: 0);
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    for (var index = position.offset;
    index < textEditingValue.text.length;
    index += 1) {
      if (!TextLayoutMetrics.isWhitespace(
          textEditingValue.text.codeUnitAt(index))) {
        return TextPosition(offset: index + 1);
      }
    }
    return TextPosition(offset: textEditingValue.text.length);
  }
}
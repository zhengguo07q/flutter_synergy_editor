import 'package:flutter/services.dart';

/// 在文档中指定的位置检索逻辑文本边界的接口(left-closed-right-open)。
///
/// 根据[TextBoundary]的实现，输入[TextPosition]可以指向一个代码单元，
/// 或两个代码之间的位置单位(如果选择是，可以用插入符号直观地表示)崩溃到那个位置)。
///
/// 例如，[LineBreakBoundary]将输入[TextPosition]解释为插入符号位置，
/// 因为在Flutter中插入符号通常绘制在[TextPosition]所指向的字符和它的前一个字符之间，
/// 而[LineBreakBoundary]关心输入[TextPosition]的亲和度。
/// 然而，大多数其他文本边界将输入[TextPosition]解释为文档中代码单元的位置，
/// 因为给定文本中的代码单元，更容易推断出文本边界。
///
/// 将“基于代码单元”[_TextBoundary]转换为“基于插入符号位置”，
/// 使用[CollapsedSelectionBoundary]组合符。
abstract class TextBoundary {
  const TextBoundary();

  TextEditingValue get textEditingValue;

  /// 返回给定位置的前导文本边界(包括前导文本边界)。
  TextPosition getLeadingTextBoundaryAt(TextPosition position);

  /// 返回给定位置的尾随文本边界(互斥)。
  TextPosition getTrailingTextBoundaryAt(TextPosition position);

  /// 得到文本边框范围
  TextRange getTextBoundaryAt(TextPosition position) {
    return TextRange(
      start: getLeadingTextBoundaryAt(position).offset,
      end: getTrailingTextBoundaryAt(position).offset,
    );
  }
}

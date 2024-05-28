import 'package:flutter/rendering.dart';
import 'package:slate/slate.dart';

extension RenderBoxExtension on RenderBox {
  bool containsOffset(Offset offset) {
    final offsetSelf = (parentData! as BoxParentData).offset;
    return (offsetSelf & size).contains(offset);
  }
}

abstract class RenderContentProxyBox implements RenderBox {
  /// 优化的行高
  double getPreferredLineHeight();

  /// 根据文本位置得到光标位置
  Offset getOffsetForCaret(TextPosition position, Rect? caretPrototype);

  /// 根据光标位置得到文本位置
  TextPosition getPositionForOffset(Offset offset);

  /// 返回给定处字形的支杆边界高度
  double? getFullHeightForCaret(TextPosition position);

  /// 以给定的偏移量返回单词的文本范围
  TextRange getWordBoundary(TextPosition position);

  /// 返回绑定给定选择的矩形列表
  List<TextBox> getBoxesForSelection(TextSelection textSelection);
}

/// 所有的节点渲染对象都需要继承
abstract class RenderEditableBox extends RenderBox {
  Node get node;

  TextPosition globalToLocalPosition(TextPosition position);

  /// 优化的行高
  double preferredLineHeight(TextPosition position);

  /// 根据文本位置得到光标位置
  Offset getOffsetForCaret(TextPosition position);

  /// 根据光标位置得到文本位置
  TextPosition getPositionForOffset(Offset offset);

  /// 得到上面的行的同一个文本位置
  TextPosition? getPositionAbove(TextPosition position);

  /// 得到下面的行的同一个文本位置
  TextPosition? getPositionBelow(TextPosition position);

  /// 得到单词范围
  TextRange getWordBoundary(TextPosition position);

  /// 得到行范围
  TextRange getLineBoundary(TextPosition position);

  TextSelectionPoint getBaseEndpointForSelection(TextSelection textSelection);

  TextSelectionPoint getExtentEndpointForSelection(TextSelection textSelection);

  /// 返回插入符号原型在给定文本位置的[Rect]。
  Rect getCaretPrototype(TextPosition position);

  Rect getLocalRectForCaret(TextPosition position);
}

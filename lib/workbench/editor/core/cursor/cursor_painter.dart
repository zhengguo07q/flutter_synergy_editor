import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../box.dart';
import 'cursor_style.dart';

///光标绘制类，在{Canvas}上进行绘制
class CursorPainter {
  CursorPainter({
    required this.editable,
    required this.style,
    required this.prototype,
    required this.color,
    required this.devicePixelRatio,
  });

  /// 真正绘制文本的结构代理
  final RenderContentProxyBox? editable;
  /// 光标样式
  final CursorStyle style;

  /// 光标的大小原型, 在不同的平台，光标大小不一样
  final Rect prototype;
  /// 光标颜色
  final Color color;
  /// 设备像素比例
  final double devicePixelRatio;

  /// 绘制光标
  void paint(
      Canvas canvas, Offset offset, TextPosition position, bool lineHasEmbed) {
    // 相对于全局的{x, y}坐标， 它的父级渲染对象是编辑器
    var relativeCaretOffset = editable!.getOffsetForCaret(position, prototype);
    if (lineHasEmbed && relativeCaretOffset == Offset.zero) {
      // 是嵌入的，而且当前找出来的位置为0，说明找错了。 找前面一个字符
      relativeCaretOffset = editable!.getOffsetForCaret(
          TextPosition(
              offset: position.offset - 1, affinity: position.affinity),
          prototype);
      // 硬编码为字符宽度的估计值为6
      relativeCaretOffset =
          Offset(relativeCaretOffset.dx + 6, relativeCaretOffset.dy);
    }

    final caretOffset = relativeCaretOffset + offset;
    // 移动光标位置的偏移
    var caretRect = prototype.shift(caretOffset);
    // 移动给定的样式偏移
    if (style.offset != null) {
      caretRect = caretRect.shift(style.offset!);
    }
    // 裁剪时移动到开头位置
    if (caretRect.left < 0.0) {
      // 对于iOS，当光标位于行首时，它可能会被滚动视图剪切。
      // 我们保证这种事不会在这里发生。
      // 这可能导致光标被绘制得更靠近右边的字符，但这比绘制剪切的光标更好(甚至光标完全隐藏)。
      caretRect = caretRect.shift(Offset(-caretRect.left, 0));
    }

    // 需要绘制的光标高度
    final caretHeight = editable!.getFullHeightForCaret(position);
    if (caretHeight != null) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          // 当不在iOS上时，覆盖高度以获取TextPosition处字形的完整高度。
          // iOS用特殊的处理方法来创建一个更高的插入符号。
          caretRect = Rect.fromLTWH(
            caretRect.left,
            caretRect.top - 2.0,
            caretRect.width,
            caretHeight,
          );
          break;
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          // 将插入符号沿文本垂直居中。
          caretRect = Rect.fromLTWH(
            caretRect.left,
            caretRect.top + (caretHeight - caretRect.height) / 2,
            caretRect.width,
            caretRect.height,
          );
          break;
        default:
          throw UnimplementedError();
      }
    }

    // 完美的坐标
    final pixelPerfectOffset = _getPixelPerfectCursorOffset(caretRect);
    if (!pixelPerfectOffset.isFinite) {
      return;
    }
    caretRect = caretRect.shift(pixelPerfectOffset);

    // 绘制
    final paint = Paint()..color = color;
    if (style.radius == null) {
      canvas.drawRect(caretRect, paint);
    } else {
      final caretRRect = RRect.fromRectAndRadius(caretRect, style.radius!);
      canvas.drawRRect(caretRRect, paint);
    }
  }

  /// 获得像素完美的光标偏移
  ///
  /// 屏幕的大小调整可能导致光标的四舍五入计算出来的位置不准确， 在这里恢复正常大小后再进行计算
  Offset _getPixelPerfectCursorOffset(Rect caretRect) {
    final caretPosition = editable!.localToGlobal(caretRect.topLeft);
    final pixelMultiple = 1.0 / devicePixelRatio;

    final pixelPerfectOffsetX = caretPosition.dx.isFinite
        ? (caretPosition.dx / pixelMultiple).round() * pixelMultiple -
            caretPosition.dx
        : caretPosition.dx;
    final pixelPerfectOffsetY = caretPosition.dy.isFinite
        ? (caretPosition.dy / pixelMultiple).round() * pixelMultiple -
            caretPosition.dy
        : caretPosition.dy;

    return Offset(pixelPerfectOffsetX, pixelPerfectOffsetY);
  }
}

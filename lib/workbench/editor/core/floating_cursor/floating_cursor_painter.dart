import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../cursor/cursor_style.dart';
import 'floating_cursor_constant.dart';

/// IOS的浮动光标绘制
class FloatingCursorPainter {
  FloatingCursorPainter({
    required this.floatingCursorRect,
    required this.style,
  });

  /// 光标样式
  CursorStyle style;
  /// 浮动光标的绘制矩形
  Rect? floatingCursorRect;

  final Paint floatingCursorPaint = Paint();

  void paint(Canvas canvas) {
    final floatingCursorRect = this.floatingCursorRect;
    final floatingCursorColor = style.color.withOpacity(0.75);
    if (floatingCursorRect == null) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(floatingCursorRect, kFloatingCaretRadius),
      floatingCursorPaint..color = floatingCursorColor,
    );
  }
}

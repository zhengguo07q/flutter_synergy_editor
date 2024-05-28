import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../main/editor_abstract.dart';
import '../cursor/cursor_controller.dart';
import 'floating_cursor_constant.dart';
import 'floating_cursor_painter.dart';

/// 浮动光标控制器
///
/// 在IOS屏幕上， 处于光标状态，长按的时候会触发此功能
/// 触发的时候，底层的[TextInputClient] 会调用[setFloatingCursor] 函数来告诉外面逻辑，浮动光标被触发
/// 执行过程中， 我们需要知道被触发时候的一些显示效果还有要被显示的位置
class FloatingCursorController {
  FloatingCursorController({
    required CursorController cursorController,
    required this.floatingCursorDisabled,
    required this.renderEditor,
  }) : _cursorController = cursorController;

  /// 是否禁用浮动光标
  final bool floatingCursorDisabled;

  /// 光标控制器
  final CursorController _cursorController;

  /// 编辑器绘制器
  final AbstractEditorRenderBox renderEditor;

  /// 浮动光标是否开启
  bool _floatingCursorOn = false;

  /// 浮动的光标的位置
  Rect? _floatingCursorRect;

  /// 获得浮动光标绘制器
  FloatingCursorPainter get _floatingCursorPainter => FloatingCursorPainter(
        floatingCursorRect: _floatingCursorRect,
        style: _cursorController.style,
      );

  /// 触发浮动光标时文本的位置
  TextPosition get floatingCursorTextPosition => _floatingCursorTextPosition;
  late TextPosition _floatingCursorTextPosition;

  /// 浮动光标的控制器
  late AnimationController _floatingCursorResetController;
  AnimationController get floatingCursorResetController =>
      _floatingCursorResetController;

  /// 绘制浮动光标
  void paintFloatingCursor(PaintingContext context, Offset offset) {
    _floatingCursorPainter.paint(context.canvas);
  }

  Offset _relativeOrigin = Offset.zero;

  /// 保存的上一次光标位置
  Offset? _previousOffset;

  /// 是否需要重置远点
  bool _resetOriginOnLeft = false;
  bool _resetOriginOnRight = false;
  bool _resetOriginOnTop = false;
  bool _resetOriginOnBottom = false;

  /// 设置浮动光标位置
  ///
  /// 这里最终会在这个子节点里面取获取位置
  /// [boundedOffset] 当前动画所需要到的位置
  void setFloatingCursor(FloatingCursorDragState dragState,
      Offset boundedOffset, TextPosition textPosition,
      {double? resetLerpValue}) {
    if (floatingCursorDisabled) return;

    //
    if (dragState == FloatingCursorDragState.Start) {
      resetOrigin();
    }
    // 不是结束状态，则代表当前浮动光标正在开启
    _floatingCursorOn = dragState != FloatingCursorDragState.End;
    // 浮动光标在启动中
    if (_floatingCursorOn) {
      // 文本位置
      _floatingCursorTextPosition = textPosition;
      // 调整重置这个浮动光标大小
      final sizeAdjustment = resetLerpValue != null
          ? EdgeInsets.lerp(
              kFloatingCaretSizeIncrease, EdgeInsets.zero, resetLerpValue)!
          : kFloatingCaretSizeIncrease;
      final child = renderEditor.childAtPosition(textPosition);
      // 得到这个子组件的光标大小的原型
      final caretPrototype =
          child.getCaretPrototype(child.globalToLocalPosition(textPosition));
      // 放大这个光标的原型并且偏移到传递过来的位置上去
      _floatingCursorRect =
          sizeAdjustment.inflateRect(caretPrototype).shift(boundedOffset);
      _cursorController
          .setFloatingCursorTextPosition(_floatingCursorTextPosition);
    } else {
      _floatingCursorRect = null;
      _cursorController.setFloatingCursorTextPosition(null);
    }
  }

  /// 返回编辑器中浮动光标允许存在的边界， 就是编辑器的内部出现的边界
  Offset calculateBoundedFloatingCursorOffset(
      Offset rawCursorOffset, double preferredLineHeight) {
    var deltaPosition = Offset.zero;
    final topBound = kFloatingCursorAddedMargin.top;
    // 计算最可能的底部边框
    final bottomBound = renderEditor.size.height -
        preferredLineHeight +
        kFloatingCursorAddedMargin.bottom;
    final leftBound = kFloatingCursorAddedMargin.left;
    final rightBound =
        renderEditor.size.width - kFloatingCursorAddedMargin.right;

    if (_previousOffset != null) {
      deltaPosition = rawCursorOffset - _previousOffset!;
    }

    //如果原始光标的偏移量已经离开了边缘，我们希望在用户拖拽回字段时重置拖动的相对原点。
    // 就是拖出编辑器边界时，重置到里面，避免拖出边界
    if (_resetOriginOnLeft && deltaPosition.dx > 0) {
      _relativeOrigin =
          Offset(rawCursorOffset.dx - leftBound, _relativeOrigin.dy);
      _resetOriginOnLeft = false;
    } else if (_resetOriginOnRight && deltaPosition.dx < 0) {
      _relativeOrigin =
          Offset(rawCursorOffset.dx - rightBound, _relativeOrigin.dy);
      _resetOriginOnRight = false;
    }
    if (_resetOriginOnTop && deltaPosition.dy > 0) {
      _relativeOrigin =
          Offset(_relativeOrigin.dx, rawCursorOffset.dy - topBound);
      _resetOriginOnTop = false;
    } else if (_resetOriginOnBottom && deltaPosition.dy < 0) {
      _relativeOrigin =
          Offset(_relativeOrigin.dx, rawCursorOffset.dy - bottomBound);
      _resetOriginOnBottom = false;
    }

    final currentX = rawCursorOffset.dx - _relativeOrigin.dx;
    final currentY = rawCursorOffset.dy - _relativeOrigin.dy;
    final double adjustedX =
        math.min(math.max(currentX, leftBound), rightBound);
    final double adjustedY =
        math.min(math.max(currentY, topBound), bottomBound);
    final adjustedOffset = Offset(adjustedX, adjustedY);

    if (currentX < leftBound && deltaPosition.dx < 0) {
      _resetOriginOnLeft = true;
    } else if (currentX > rightBound && deltaPosition.dx > 0) {
      _resetOriginOnRight = true;
    }
    if (currentY < topBound && deltaPosition.dy < 0) {
      _resetOriginOnTop = true;
    } else if (currentY > bottomBound && deltaPosition.dy > 0) {
      _resetOriginOnBottom = true;
    }

    _previousOffset = rawCursorOffset;

    return adjustedOffset;
  }

  void resetOrigin() {
    _relativeOrigin = Offset.zero;
    _previousOffset = null;
    _resetOriginOnLeft = false;
    _resetOriginOnTop = false;
    _resetOriginOnRight = false;
    _resetOriginOnBottom = false;
  }
}

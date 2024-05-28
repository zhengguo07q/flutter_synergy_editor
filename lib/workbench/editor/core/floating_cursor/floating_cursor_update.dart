import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../main/editor_logic.dart';

class FloatingCursorUpdate {
  FloatingCursorUpdate({required this.editorLogicState}) {
    floatingCursorResetController =
        AnimationController(vsync: editorLogicState);
    floatingCursorResetController.addListener(onEventFloatingCursorResetTick);
  }

  /// 编辑器绘制器
  final AbstractEditorLogic editorLogicState;

  /// 浮动光标的控制器
  late AnimationController floatingCursorResetController;

  //当用户放置完浮动光标后，浮动光标移到与文本对齐的光标位置所需的时间。
  static const Duration _floatingCursorResetTime = Duration(milliseconds: 125);

  // FloatingCursorDragState.start上插入符号的原始位置。
  Rect? _startCaretRect;

  // 最近的文本位置，由浮动光标的位置决定。
  TextPosition? _lastTextPosition;

  // 从start调用开始确定的浮动光标的偏移量。
  Offset? _pointOffsetOrigin;

  // 浮动光标最近的位置。
  Offset? _lastBoundedOffset;

  // 因为光标的中心是在触摸原点以下的preferredLineHeight/2，
  // 但是触摸原点用于确定光标在哪一行，我们需要这个偏移量来正确地渲染和移动光标。
  Offset _floatingCursorOffset(TextPosition textPosition) => Offset(
      0,
      editorLogicState.renderEditor.textPositionPart
              .preferredLineHeight(textPosition) /
          2);

  /// 被[TextInputClient.updateFloatingCursor] 所调用驱动
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    final renderEditor = editorLogicState.renderEditor;
    final textPositionPart = renderEditor.textPositionPart;
    final floatingCursorController = renderEditor.floatingCursorController;
    switch (point.state) {
      case FloatingCursorDragState.Start:
        // 开始状态， 停止动画，重置
        if (floatingCursorResetController.isAnimating) {
          floatingCursorResetController.stop();
          onEventFloatingCursorResetTick();
        }
        //当前点击位置的偏移，我们想要发送以原点(0,0)为中心的点，所以我们缓存了位置。
        _pointOffsetOrigin = point.offset;

        final currentTextPosition =
            TextPosition(offset: renderEditor.selection.baseOffset);
        _startCaretRect =
            textPositionPart.getLocalRectForCaret(currentTextPosition);
        // 开始时的偏移，为原来正常时候的中心点
        _lastBoundedOffset = _startCaretRect!.center -
            _floatingCursorOffset(currentTextPosition);
        _lastTextPosition = currentTextPosition;
        // 设置第一次浮动光标的位置信息
        floatingCursorController.setFloatingCursor(
            point.state, _lastBoundedOffset!, _lastTextPosition!);
        break;
      case FloatingCursorDragState.Update:
        assert(_lastTextPosition != null, 'Last part position was not set');
        final floatingCursorOffset = _floatingCursorOffset(_lastTextPosition!);
        final centeredPoint = point.offset! - _pointOffsetOrigin!;
        final rawCursorOffset =
            _startCaretRect!.center + centeredPoint - floatingCursorOffset;

        final preferredLineHeight =
            textPositionPart.preferredLineHeight(_lastTextPosition!);
        _lastBoundedOffset =
            floatingCursorController.calculateBoundedFloatingCursorOffset(
          rawCursorOffset,
          preferredLineHeight,
        );
        _lastTextPosition = textPositionPart.getPositionForOffset(renderEditor
            .localToGlobal(_lastBoundedOffset! + floatingCursorOffset));
        floatingCursorController.setFloatingCursor(
            point.state, _lastBoundedOffset!, _lastTextPosition!);
        final newSelection = TextSelection.collapsed(
            offset: _lastTextPosition!.offset,
            affinity: _lastTextPosition!.affinity);
        // 将光标移动设置为浮动，将滚动视图将背景光标带入视图
        renderEditor.onSelectionChanged(
            newSelection, SelectionChangedCause.forcePress);
        break;
      case FloatingCursorDragState.End:
        // 如果没有更新，则跳过动画。
        if (_lastTextPosition != null && _lastBoundedOffset != null) {
          floatingCursorResetController
            ..value = 0.0
            ..animateTo(1,
                duration: _floatingCursorResetTime, curve: Curves.decelerate);
        }
        break;
    }
  }

  /// 重置浮动光标的一些位置信息
  ///
  /// 根据动画控制器的值指定浮动光标的尺寸和位置。
  /// 浮动游标被调整大小(见[setFloatingCursor])和重新定位(浮动游标位置和当前背景游标位置之间的线性插值)
  void onEventFloatingCursorResetTick() {
    final renderEditor = editorLogicState.renderEditor;
    final textPositionPart = renderEditor.textPositionPart;
    final floatingCursorController = renderEditor.floatingCursorController;
    // 计算需要光标需要返回的位置
    final finalPosition =
        textPositionPart.getLocalRectForCaret(_lastTextPosition!).centerLeft -
            _floatingCursorOffset(_lastTextPosition!);
    // 这个动画快完成时，设置到相关位置并清理掉缓存
    if (floatingCursorResetController.isCompleted) {
      floatingCursorController.setFloatingCursor(
          FloatingCursorDragState.End, finalPosition, _lastTextPosition!);
      _startCaretRect = null;
      _lastTextPosition = null;
      _pointOffsetOrigin = null;
      _lastBoundedOffset = null;
    } else {
      // 计算当前动画所需要到的位置
      final lerpValue = floatingCursorResetController.value;
      final lerpX =
          lerpDouble(_lastBoundedOffset!.dx, finalPosition.dx, lerpValue)!;
      final lerpY =
          lerpDouble(_lastBoundedOffset!.dy, finalPosition.dy, lerpValue)!;

      floatingCursorController.setFloatingCursor(FloatingCursorDragState.Update,
          Offset(lerpX, lerpY), _lastTextPosition!,
          resetLerpValue: lerpValue);
    }
  }

  void dispose() {
    floatingCursorResetController.dispose();
  }
}

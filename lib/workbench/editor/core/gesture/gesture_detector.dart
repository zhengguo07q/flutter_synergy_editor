import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// 文本手势组件
/// 用来给整个文本添加触摸事件，包含
///   1，用力触摸
///   2，简单触摸
///   3，简单长按
///   4，双击
///   5，拖动选择
/// 这里面的逻辑只是纯粹的二次判断逻辑，不包含业务逻辑，业务逻辑通过[DetectorBuilder]传递
///
///
/// 这是一个全局的事件管理器
/// 在这里
class TextGestureDetector extends ConsumerStatefulWidget {
  const TextGestureDetector({
    required this.child,
    this.onTapDown,
    this.onForcePressStart,
    this.onForcePressEnd,
    this.onSingleTapUp,
    this.onSingleTapCancel,
    this.onSingleLongTapStart,
    this.onSingleLongTapMoveUpdate,
    this.onSingleLongTapEnd,
    this.onDoubleTapDown,
    this.onDragSelectionStart,
    this.onDragSelectionUpdate,
    this.onDragSelectionEnd,
    this.behavior,
    Key? key,
  }) : super(key: key);

  final GestureTapDownCallback? onTapDown;

  final GestureForcePressStartCallback? onForcePressStart;

  final GestureForcePressEndCallback? onForcePressEnd;

  final GestureTapUpCallback? onSingleTapUp;

  final GestureTapCancelCallback? onSingleTapCancel;

  final GestureLongPressStartCallback? onSingleLongTapStart;

  final GestureLongPressMoveUpdateCallback? onSingleLongTapMoveUpdate;

  final GestureLongPressEndCallback? onSingleLongTapEnd;

  final GestureTapDownCallback? onDoubleTapDown;

  final GestureDragStartCallback? onDragSelectionStart;

  final DragSelectionUpdateCallback? onDragSelectionUpdate;

  final GestureDragEndCallback? onDragSelectionEnd;

  final HitTestBehavior? behavior;

  final Widget child;

  @override
  _TextGestureDetectorState createState() => _TextGestureDetectorState();
}

class _TextGestureDetectorState extends ConsumerState<TextGestureDetector> {
  /// 双击定时器
  Timer? _doubleTapTimer;

  /// 上一次点击偏移，全局位置
  Offset? _lastTapOffset;

  /// 双击中
  bool _isDoubleTap = false;

  @override
  void dispose() {
    _doubleTapTimer?.cancel();
    _dragUpdateThrottleTimer?.cancel();
    super.dispose();
  }

  ///################################点击######################################

  /// 处理点击按下, 一般用来保存第一个点击位置
  void _handleTapDown(TapDownDetails details) {
    // renderObject.resetTapDownStatus();
    // 调用外部的事件函数
    if (widget.onTapDown != null) {
      widget.onTapDown!(details);
    }
    // 检查双击
    if (_doubleTapTimer != null &&
        _isWithinDoubleTapTolerance(details.globalPosition)) {
      // 调用外部的双击函数
      if (widget.onDoubleTapDown != null) {
        widget.onDoubleTapDown!(details);
      }

      // 双击完成后取消
      _doubleTapTimer!.cancel();
      _doubleTapTimeout();
      _isDoubleTap = true;
    }
  }

  /// 处理点击弹起， 触发显示光标和开启双击计时
  void _handleTapUp(TapUpDetails details) {
    if (!_isDoubleTap) {
      if (widget.onSingleTapUp != null) {
        widget.onSingleTapUp!(details);
      }
      _lastTapOffset = details.globalPosition;
      // 启动双击定时器，300ms
      _doubleTapTimer = Timer(kDoubleTapTimeout, _doubleTapTimeout);
    }
    _isDoubleTap = false;
  }

  /// 点击取消， 什么都没做
  void _handleTapCancel() {
    if (widget.onSingleTapCancel != null) {
      widget.onSingleTapCancel!();
    }
  }

  ///################################拖拽######################################

  DragStartDetails? _lastDragStartDetails;
  DragUpdateDetails? _lastDragUpdateDetails;
  Timer? _dragUpdateThrottleTimer;

  /// 处理拖拽开始， 开启选择区域
  void _handleDragStart(DragStartDetails details) {
    assert(_lastDragStartDetails == null);
    _lastDragStartDetails = details;
    if (widget.onDragSelectionStart != null) {
      widget.onDragSelectionStart!(details);
    }
  }

  /// 处理拖拽更新
  void _handleDragUpdate(DragUpdateDetails details) {
    _lastDragUpdateDetails = details;
    _dragUpdateThrottleTimer ??=
        Timer(const Duration(milliseconds: 50), _handleDragUpdateThrottled);
  }

  /// 随时更新选择区域
  void _handleDragUpdateThrottled() {
    assert(_lastDragStartDetails != null);
    assert(_lastDragUpdateDetails != null);
    if (widget.onDragSelectionUpdate != null) {
      widget.onDragSelectionUpdate!(
          _lastDragStartDetails!, _lastDragUpdateDetails!);
    }
    _dragUpdateThrottleTimer = null;
    _lastDragUpdateDetails = null;
  }

  /// 处理拖拽结束
  void _handleDragEnd(DragEndDetails details) {
    assert(_lastDragStartDetails != null);
    if (_dragUpdateThrottleTimer != null) {
      _dragUpdateThrottleTimer!.cancel();
      _handleDragUpdateThrottled();
    }
    if (widget.onDragSelectionEnd != null) {
      widget.onDragSelectionEnd!(details);
    }
    _dragUpdateThrottleTimer = null;
    _lastDragStartDetails = null;
    _lastDragUpdateDetails = null;
  }

  ///################################按压######################################

  /// 按压开始， 选择单词
  void _forcePressStarted(ForcePressDetails details) {
    _doubleTapTimer?.cancel();
    _doubleTapTimer = null;
    if (widget.onForcePressStart != null) {
      widget.onForcePressStart!(details);
    }
  }

  /// 按压结束，开启工具栏
  void _forcePressEnded(ForcePressDetails details) {
    if (widget.onForcePressEnd != null) {
      widget.onForcePressEnd!(details);
    }
  }

  ///################################长按######################################

  /// 处理长按开始， 选区开始
  void _handleLongPressStart(LongPressStartDetails details) {
    if (!_isDoubleTap && widget.onSingleLongTapStart != null) {
      widget.onSingleLongTapStart!(details);
    }
  }

  /// 处理长按移动更新， 更新选区位置
  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isDoubleTap && widget.onSingleLongTapMoveUpdate != null) {
      widget.onSingleLongTapMoveUpdate!(details);
    }
  }

  /// 处理长按结束， 弹出工具栏
  void _handleLongPressEnd(LongPressEndDetails details) {
    if (!_isDoubleTap && widget.onSingleLongTapEnd != null) {
      widget.onSingleLongTapEnd!(details);
    }
    _isDoubleTap = false;
  }

  /// 双击超时， 去掉双击定时
  void _doubleTapTimeout() {
    _doubleTapTimer = null;
    _lastTapOffset = null;
  }

  /// 检查是否在双击范围内
  bool _isWithinDoubleTapTolerance(Offset secondTapOffset) {
    if (_lastTapOffset == null) {
      return false;
    }

    return (secondTapOffset - _lastTapOffset!).distance <= kDoubleTapSlop;
  }

  /// 构建手势事件驱动
  @override
  Widget build(BuildContext context) {
    // 手势构建工厂
    final gestures = <Type, GestureRecognizerFactory>{};
    // Tap
    gestures[TapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
      () => TapGestureRecognizer(debugOwner: this),
      (instance) {
        instance
          ..onTapDown = _handleTapDown
          ..onTapUp = _handleTapUp
          ..onTapCancel = _handleTapCancel;
      },
    );

    // LongTap
    if (widget.onSingleLongTapStart != null ||
        widget.onSingleLongTapMoveUpdate != null ||
        widget.onSingleLongTapEnd != null) {
      gestures[LongPressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
        () => LongPressGestureRecognizer(
          debugOwner: this,
          supportedDevices: <PointerDeviceKind>{PointerDeviceKind.touch},
        ),
        (instance) {
          instance
            ..onLongPressStart = _handleLongPressStart
            ..onLongPressMoveUpdate = _handleLongPressMoveUpdate
            ..onLongPressEnd = _handleLongPressEnd;
        },
      );
    }

    // DragSelection
    if (widget.onDragSelectionStart != null ||
        widget.onDragSelectionUpdate != null ||
        widget.onDragSelectionEnd != null) {
      gestures[HorizontalDragGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
        () => HorizontalDragGestureRecognizer(
          debugOwner: this,
          supportedDevices: <PointerDeviceKind>{PointerDeviceKind.mouse},
        ),
        (instance) {
          instance
            ..dragStartBehavior = DragStartBehavior.down
            ..onStart = _handleDragStart
            ..onUpdate = _handleDragUpdate
            ..onEnd = _handleDragEnd;
        },
      );
    }

    // ForcePress
    if (widget.onForcePressStart != null || widget.onForcePressEnd != null) {
      gestures[ForcePressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ForcePressGestureRecognizer>(
        () => ForcePressGestureRecognizer(debugOwner: this),
        (instance) {
          instance
            ..onStart =
                widget.onForcePressStart != null ? _forcePressStarted : null
            ..onEnd = widget.onForcePressEnd != null ? _forcePressEnded : null;
        },
      );
    }
    // 创建手势检查器
    return RawGestureDetector(
      gestures: gestures,
      excludeFromSemantics: true,
      behavior: widget.behavior,
      child: widget.child,
    );
  }
}

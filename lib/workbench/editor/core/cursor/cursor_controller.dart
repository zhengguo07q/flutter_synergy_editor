import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:slate/slate.dart';

import 'cursor_constant.dart';
import 'cursor_style.dart';

///光标控制器类
class CursorController extends ChangeNotifier {
  CursorController({
    required this.show,
    required CursorStyle style,
    required TickerProvider tickerProvider,
  })  : _style = style,
        blink = ValueNotifier(false),
        color = ValueNotifier(style.color) {
    _blinkOpacityCont =
        AnimationController(vsync: tickerProvider, duration: kFadeDuration);
    _blinkOpacityCont.addListener(_onTimerColorTick);
  }
  /// 光标从不可见到可见的动画
  late AnimationController _blinkOpacityCont;
  /// 光标定时器
  Timer? _cursorTimer;
  /// 光标是否可见
  bool _targetCursorVisibility = false;

  final ValueNotifier<bool> show;
  final ValueNotifier<bool> blink;
  final ValueNotifier<Color> color;

  /// 光标样式
  CursorStyle _style;
  CursorStyle get style => _style;
  set style(CursorStyle value) {
    if (_style == value) return;
    _style = value;
    notifyListeners();
  }

  /// 设置光标样式和是否显示光标
  setCursorValue(CursorStyle cursorStyle, bool showCursor) {
    style = cursorStyle;
    show.value = showCursor;
  }

  /// 开启光标闪烁
  void startCursorTimer() {
    _targetCursorVisibility = true;
    _blinkOpacityCont.value = 1.0;

    _cursorTimer = style.opacityAnimates
        ? Timer.periodic(const Duration(milliseconds: 150), _onTimerCursorWaitForStart)
        : Timer.periodic(const Duration(milliseconds: 500), _onTimerCursorTick);
  }

  /// 停止之前可能存在的闪烁光标
  void stopCursorTimer({bool resetCharTicks = true}) {
    _cursorTimer?.cancel();
    _cursorTimer = null;
    _targetCursorVisibility = false;
    _blinkOpacityCont.value = 0.0;

    // 停止之前的半透明动画效果
    if (style.opacityAnimates) {
      _blinkOpacityCont
        ..stop()
        ..value = 0.0;
    }
  }

  /// 外界调用，开启或停止光标闪烁
  void startOrStopCursorTimerIfNeeded(bool hasFocus, TextSelection selection) {
    if (show.value &&
        _cursorTimer == null &&
        hasFocus &&
        selection.isCollapsed) {
      startCursorTimer();
    } else if (_cursorTimer != null && (!hasFocus || !selection.isCollapsed)) {
      stopCursorTimer();
    }
  }

  /// 光标等待开始， 多增加150ms延迟
  void _onTimerCursorWaitForStart(Timer timer) {
    _cursorTimer?.cancel();
    _cursorTimer =
        Timer.periodic(const Duration(milliseconds: 500), _onTimerCursorTick);
  }

  /// 光标定时器回调
  ///
  /// 500毫秒一次闪烁，如果有透明动画，则动画缓动到，不然则是直接切换
  void _onTimerCursorTick(Timer timer) {
    // 切换可见性
    _targetCursorVisibility = !_targetCursorVisibility;
    final targetOpacity = _targetCursorVisibility ? 1.0 : 0.0;
    if (style.opacityAnimates) {
      _blinkOpacityCont.animateTo(targetOpacity, curve: Curves.easeOut);
    } else {
      _blinkOpacityCont.value = targetOpacity;
    }
  }

  /// 光标动画回调
  void _onTimerColorTick() {
    // 颜色透明度调整
    color.value = _style.color.withOpacity(_blinkOpacityCont.value);
    blink.value = show.value && _blinkOpacityCont.value > 0;
  }

  @override
  void dispose() {
    _blinkOpacityCont.removeListener(_onTimerColorTick);
    stopCursorTimer();
    _blinkOpacityCont.dispose();
    assert(_cursorTimer == null);
    super.dispose();
  }

  /// 用来监听浮动光标位置改变， 当浮动光标位置改变后， 需要改变选取光标位置
  final ValueNotifier<TextPosition?> _floatingCursorTextPosition =
      ValueNotifier(null);

  ValueNotifier<TextPosition?> get floatingCursorTextPosition =>
      _floatingCursorTextPosition;

  /// 外地给设置光标通知的
  void setFloatingCursorTextPosition(TextPosition? position) =>
      _floatingCursorTextPosition.value = position;

  /// 用来判断浮动光标是否在激活状态
  bool get isFloatingCursorActive => floatingCursorTextPosition.value != null;
}

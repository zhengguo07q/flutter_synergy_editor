import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:thinkhub_client/workbench/editor/main/editor_abstract.dart';

import '../../main/editor_builder.dart';
import '../../main/editor_logic.dart';
import 'gesture_detector.dart';

/// 构建器是真正的去处理业务逻辑层事件的地方。
/// 主要有以下几种作用
///   1，[SelectionGestureDetectorBuilder.build] 构建事件处理底层逻辑
///   2，去处理编辑器层的业务逻辑，
/// 目前编辑器层面的业务逻辑做了再次抽象。分成了继承的两层。
///   1，[SelectionGestureDetectorBuilder] 主要负责选区选择相关
///   2，[TextEditorSelectionGestureDetectorBuilder] 主要是与组件逻辑触发相关，比如说链接等
///
/// 因为真实选择逻辑与渲染器的信息有关，比如说位置等

//typedef EmbedBuilder = Widget Function(BuildContext context, Node node);

///文本选区事件观察器构建委派
abstract class SelectionGestureDetectorBuilderDelegate {
  GlobalKey<AbstractEditorLogic> getEditableTextKey();

  bool getForcePressEnabled();

  bool getSelectionEnabled();
}

/// 文本选区事件观察器构建器
class SelectionGestureDetectorBuilder {
  SelectionGestureDetectorBuilder(this.delegate);

  final SelectionGestureDetectorBuilderDelegate delegate;

  /// 是否要显示选择工具栏
  bool shouldShowSelectionToolbar = true;

  /// 是否处于块状显示模式
  bool blockMode = false;

  /// 获得编辑器
  AbstractEditorLogic? getEditor() {
    return delegate.getEditableTextKey().currentState;
  }

  /// 获得渲染器
  AbstractEditorRenderBox? getRenderEditor() {
    return getEditor()!.renderEditor;
  }

  ///#################################点击###############################################

  /// 简单的触摸弹起，选择单个单词
  void onSingleTapUp(TapUpDetails details) {
    final renderBox = getRenderEditor()!;
    if (delegate.getSelectionEnabled()) {
      renderBox.textSelectionPart.selectWordEdge(SelectionChangedCause.tap);
    }
  }

  void onSingleTapCancel() {}

  /// 简单的触摸按下，除开保存位置外不做其他，行为在弹起里做
  void onTapDown(TapDownDetails details) {
    getRenderEditor()!.textSelectionPart.handleTapDown(details);

    final kind = details.kind;
    shouldShowSelectionToolbar = kind == null ||
        kind == PointerDeviceKind.touch ||
        kind == PointerDeviceKind.stylus ||
        kind == PointerDeviceKind.mouse;
  }

  ///#################################双击###############################################

  /// 双击按下，选择单词并弹出选择工具栏
  void onDoubleTapDown(TapDownDetails details) {
    final renderBox = getRenderEditor()!;
    if (delegate.getSelectionEnabled()) {
      renderBox.textSelectionPart.selectWord(SelectionChangedCause.tap);
      if (shouldShowSelectionToolbar) {
        getEditor()!.showToolbar();
      }
    }
  }

  ///#################################按压###############################################

  /// 选择开始，选择文本，设置准备开始显示工具栏
  void onForcePressStart(ForcePressDetails details) {
    print('onForcePressStart');
    final renderBox = getRenderEditor()!;
    assert(delegate.getForcePressEnabled());
    // 显示工具栏
    shouldShowSelectionToolbar = true;
    // 设置选择范围
    if (delegate.getSelectionEnabled()) {
      renderBox.textSelectionPart.selectWordsInRange(
          details.globalPosition, null, SelectionChangedCause.forcePress);
    }
  }

  /// 选择结束，选择文本，结束后显示工具栏
  void onForcePressEnd(ForcePressDetails details) {
    assert(delegate.getForcePressEnabled());
    final renderBox = getRenderEditor()!;
    // 设置选择范围
    print('onForcePressEnd');
    renderBox.textSelectionPart.selectWordsInRange(
        details.globalPosition, null, SelectionChangedCause.forcePress);
    // 开始设了应该显示工具栏，现在启动显示工具栏
    if (shouldShowSelectionToolbar) {
      getEditor()!.showToolbar();
    }
  }

  ///#################################长按###############################################

  /// 长按开始
  void onSingleLongTapStart(LongPressStartDetails details) {
    if (delegate.getSelectionEnabled()) {
      getRenderEditor()!.textSelectionPart.selectPositionAt(
          from: details.globalPosition, cause: SelectionChangedCause.longPress);
    }
  }

  /// 长按移动
  void onSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    if (delegate.getSelectionEnabled()) {
      getRenderEditor()!.textSelectionPart.selectPositionAt(
          from: details.globalPosition, cause: SelectionChangedCause.longPress);
    }
  }

  /// 长按结束
  void onSingleLongTapEnd(LongPressEndDetails details) {
    if (shouldShowSelectionToolbar) {
      getEditor()!.showToolbar();
    }
  }

  ///#################################拖拽###############################################

  /// 拖动选择开始
  void onDragSelectionStart(DragStartDetails details) {
    getRenderEditor()!.textSelectionPart.selectPositionAt(
        from: details.globalPosition, cause: SelectionChangedCause.drag);
  }

  /// 拖动选择更新
  void onDragSelectionUpdate(
    DragStartDetails startDetails,
    DragUpdateDetails updateDetails,
  ) {
    getRenderEditor()!.textSelectionPart.selectPositionAt(
        from: startDetails.globalPosition,
        to:updateDetails.globalPosition,
        cause: SelectionChangedCause.drag);
  }

  /// 拖动选择结束
  void onDragSelectionEnd(DragEndDetails details) {}

  Widget build(HitTestBehavior behavior, Widget child) {
    return TextGestureDetector(
      onTapDown: onTapDown,
      onForcePressStart:
          delegate.getForcePressEnabled() ? onForcePressStart : null,
      onForcePressEnd: delegate.getForcePressEnabled() ? onForcePressEnd : null,
      onSingleTapUp: onSingleTapUp,
      onSingleTapCancel: onSingleTapCancel,
      onSingleLongTapStart: onSingleLongTapStart,
      onSingleLongTapMoveUpdate: onSingleLongTapMoveUpdate,
      onSingleLongTapEnd: onSingleLongTapEnd,
      onDoubleTapDown: onDoubleTapDown,
      onDragSelectionStart: onDragSelectionStart,
      onDragSelectionUpdate: onDragSelectionUpdate,
      onDragSelectionEnd: onDragSelectionEnd,
      behavior: behavior,
      child: child,
    );
  }
}

///编辑器选区手势事件，用来处理外部的非选区相关事件
class TextEditorSelectionGestureDetectorBuilder
    extends SelectionGestureDetectorBuilder {
  TextEditorSelectionGestureDetectorBuilder(this._buildState)
      : super(_buildState);

  final EditorBuilderState _buildState;

  ///#################################按压###############################################

  /// 按压开始
  @override
  void onForcePressStart(ForcePressDetails details) {
    super.onForcePressStart(details);
    if (delegate.getSelectionEnabled() && shouldShowSelectionToolbar) {
      getEditor()!.showToolbar();
    }
  }

  /// 按压结束
  @override
  void onForcePressEnd(ForcePressDetails details) {}

  ///#################################长按###############################################

  @override
  void onSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    final renderEditor = getRenderEditor()!;
    if (_buildState.widget.onSingleLongTapMoveUpdate != null) {
      if (_buildState.widget.onSingleLongTapMoveUpdate!(
        details,
        renderEditor.textPositionPart.getPositionForOffset,
      )) {
        return;
      }
    }
    if (!delegate.getSelectionEnabled()) {
      return;
    }
    switch (Theme.of(_buildState.context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        renderEditor.textSelectionPart.selectPositionAt(
          from: details.globalPosition,
          cause: SelectionChangedCause.longPress,
        );
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        renderEditor.textSelectionPart.selectWordsInRange(
          details.globalPosition - details.offsetFromOrigin,
          details.globalPosition,
          SelectionChangedCause.longPress,
        );
        break;
      default:
        throw 'Invalid platform';
    }
  }

  /// 判断当前点击位置是不是存在
  bool _isPositionSelected(TapUpDetails details) {
    if (_buildState.widget.textHolder.localNode.isEmpty) {
      return false;
    }
    final renderEditor = getRenderEditor()!;
    final pos = renderEditor.textPositionPart
        .getPositionForOffset(details.globalPosition);
    final result = _buildState.widget.textHolder.localNode
        .querySegmentLeafNode(pos.offset);
    final line = result.item1;
    if (line == null) {
      return false;
    }
    final segmentLeaf = result.item2;
    if (segmentLeaf == null && line.length == 1) {
      _buildState.widget.textHolder
          .updateSelection(TextSelection.collapsed(offset: pos.offset));
      return true;
    }
    return false;
  }

  @override
  void onTapDown(TapDownDetails details) {
    if (_buildState.widget.onTapDown != null) {
      final renderEditor = getRenderEditor()!;
      if (_buildState.widget.onTapDown!(
        details,
        renderEditor.textPositionPart.getPositionForOffset,
      )) {
        return;
      }
    }
    super.onTapDown(details);
  }

  @override
  void onSingleTapUp(TapUpDetails details) {
    final renderEditor = getRenderEditor()!;
    if (_buildState.widget.onTapUp != null) {
      if (_buildState.widget.onTapUp!(
          details, renderEditor.textPositionPart.getPositionForOffset)) {
        return;
      }
    }

    getEditor()!.hideToolbar();

    final positionSelected = _isPositionSelected(details);

    if (delegate.getSelectionEnabled() && !positionSelected) {
      switch (Theme.of(_buildState.context).platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          switch (details.kind) {
            case PointerDeviceKind.mouse:
            case PointerDeviceKind.stylus:
            case PointerDeviceKind.invertedStylus:
              renderEditor.textSelectionPart
                  .selectPosition(SelectionChangedCause.tap);
              break;
            case PointerDeviceKind.touch:
            case PointerDeviceKind.unknown:
              renderEditor.textSelectionPart
                  .selectWordEdge(SelectionChangedCause.tap);
              break;
          }
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          renderEditor.textSelectionPart
              .selectPosition(SelectionChangedCause.tap);
          break;
      }
    }
    _buildState.requestKeyboard();
  }

  @override
  void onSingleLongTapStart(LongPressStartDetails details) {
    final renderEditor = getRenderEditor()!;
    if (_buildState.widget.onSingleLongTapStart != null) {
      if (_buildState.widget.onSingleLongTapStart!(
        details,
        renderEditor.textPositionPart.getPositionForOffset,
      )) {
        return;
      }
    }

    if (delegate.getSelectionEnabled()) {
      switch (Theme.of(_buildState.context).platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          renderEditor.textSelectionPart.selectPositionAt(
            from: details.globalPosition,
            cause: SelectionChangedCause.longPress,
          );
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          renderEditor.textSelectionPart
              .selectWord(SelectionChangedCause.longPress);
          Feedback.forLongPress(_buildState.context);
          break;
        default:
          throw 'Invalid platform';
      }
    }
  }

  @override
  void onSingleLongTapEnd(LongPressEndDetails details) {
    if (_buildState.widget.onSingleLongTapEnd != null) {
      final renderEditor = getRenderEditor();
      if (renderEditor != null) {
        if (_buildState.widget.onSingleLongTapEnd!(
          details,
          renderEditor.textPositionPart.getPositionForOffset,
        )) {
          return;
        }
      }
    }
    super.onSingleLongTapEnd(details);
  }
}

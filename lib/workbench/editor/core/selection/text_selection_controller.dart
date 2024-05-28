import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:thinkhub_client/workbench/editor/main/editor_abstract.dart';
import 'package:thinkhub_client/workbench/editor/core/selection/text_selection_handle_overlay.dart';

import '../selection/text_selection_drag.dart';

/// 选区手柄和工具栏位置
class TextSelectionController {
  TextSelectionController(
    this.value,
    this.handlesVisible,
    this.context,
    this.debugRequiredFor,
    this.toolbarLayerLink,
    this.startHandleLayerLink,
    this.endHandleLayerLink,
    this.renderObject,
    this.selectionCtrls,
    this.selectionDelegate,
    this.dragStartBehavior,
    this.onSelectionHandleTapped,
    this.clipboardStatus,
  ) {
    final overlay = Overlay.of(context, rootOverlay: true)!;

    /// 工具栏的显示动画
    _toolbarController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: overlay,
    );
  }

  TextEditingValue value;
  bool handlesVisible = false;
  final BuildContext context;
  final Widget debugRequiredFor;
  final LayerLink toolbarLayerLink;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final AbstractEditorRenderBox? renderObject;
  final TextSelectionControls selectionCtrls;
  final TextSelectionDelegate selectionDelegate;
  final DragStartBehavior dragStartBehavior;
  final VoidCallback? onSelectionHandleTapped;
  final ClipboardStatusNotifier clipboardStatus;

  /// 选择工具栏动画控制器
  late AnimationController _toolbarController;

  List<OverlayEntry>? _handles;
  OverlayEntry? toolbar;

  TextSelection get _selection => value.selection;

  Animation<double> get _toolbarOpacity => _toolbarController.view;

  /// 显示处理器
  void setHandlesVisible(bool visible) {
    if (handlesVisible == visible) {
      return;
    }
    handlesVisible = visible;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback(markNeedsBuild);
    } else {
      markNeedsBuild();
    }
  }

  /// 隐藏处理器
  void hideHandles() {
    if (_handles == null) {
      return;
    }
    _handles![0].remove();
    _handles![1].remove();
    _handles = null;
  }

  /// 隐藏工具栏
  void hideToolbar() {
    assert(toolbar != null);
    _toolbarController.stop();
    toolbar!.remove();
    toolbar = null;
  }

  /// 显示工具栏
  void showToolbar() {
    assert(toolbar == null);
    if (!_selection.isValid) return;
    toolbar = OverlayEntry(builder: _buildToolbar);
    Overlay.of(context, rootOverlay: true, debugRequiredFor: debugRequiredFor)!
        .insert(toolbar!);
    _toolbarController.forward(from: 0);
  }

  /// 构建选区句柄
  Widget _buildHandle(
      BuildContext context, TextSelectionHandlePosition position) {
    if (_selection.isCollapsed && position == TextSelectionHandlePosition.end) {
      return Container();
    }
    return Visibility(
        visible: handlesVisible,
        child: TextSelectionHandleOverlay(
          onSelectionHandleChanged: (newSelection) {
            _handleSelectionHandleChanged(newSelection, position);
          },
          onSelectionHandleTapped: onSelectionHandleTapped,
          startHandleLayerLink: startHandleLayerLink,
          endHandleLayerLink: endHandleLayerLink,
          renderObject: renderObject,
          selection: _selection,
          selectionControls: selectionCtrls,
          position: position,
          dragStartBehavior: dragStartBehavior,
        ));
  }

  /// 更新选区内容
  void update(TextEditingValue newValue) {
    if (value == newValue) {
      return;
    }
    value = newValue;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback(markNeedsBuild);
    } else {
      markNeedsBuild();
    }
  }

  void _handleSelectionHandleChanged(
      TextSelection? newSelection, TextSelectionHandlePosition position) {
    TextPosition textPosition;
    switch (position) {
      case TextSelectionHandlePosition.start:
        textPosition = newSelection != null
            ? newSelection.base
            : const TextPosition(offset: 0);
        break;
      case TextSelectionHandlePosition.end:
        textPosition = newSelection != null
            ? newSelection.extent
            : const TextPosition(offset: 0);
        break;
      default:
        throw 'Invalid position';
    }

    final currSelection = newSelection != null
        ? TextSelectionDrag(
            baseOffset: newSelection.baseOffset,
            extentOffset: newSelection.extentOffset,
            affinity: newSelection.affinity,
            isDirectional: newSelection.isDirectional,
            first: position == TextSelectionHandlePosition.start,
          )
        : null;

    selectionDelegate
      ..userUpdateTextEditingValue(
          value.copyWith(selection: currSelection, composing: TextRange.empty),
          SelectionChangedCause.drag)
      ..bringIntoView(textPosition);
  }

  /// 构建工具栏，返回一个工具栏组件
  Widget _buildToolbar(BuildContext context) {
    final textPositionComp = renderObject!.textPositionPart;
    final endpoints = renderObject!.textSelectionPart
        .getEndpointsForSelection(_selection);

    final editingRegion = Rect.fromPoints(
      renderObject!.localToGlobal(Offset.zero),
      renderObject!.localToGlobal(renderObject!.size.bottomRight(Offset.zero)),
    );

    final baseLineHeight =
        textPositionComp.preferredLineHeight(_selection.base);
    final extentLineHeight =
        textPositionComp.preferredLineHeight(_selection.extent);
    final smallestLineHeight = math.min(baseLineHeight, extentLineHeight);
    final isMultiline = endpoints.last.point.dy - endpoints.first.point.dy >
        smallestLineHeight / 2;

    final midX = isMultiline
        ? editingRegion.width / 2
        : (endpoints.first.point.dx + endpoints.last.point.dx) / 2;

    final midpoint = Offset(
      midX,
      endpoints[0].point.dy - baseLineHeight,
    );

    return FadeTransition(
      opacity: _toolbarOpacity,
      child: CompositedTransformFollower(
        link: toolbarLayerLink,
        showWhenUnlinked: false,
        offset: -editingRegion.topLeft,
        child: selectionCtrls.buildToolbar(
            context,
            editingRegion,
            baseLineHeight,
            midpoint,
            endpoints,
            selectionDelegate,
            clipboardStatus,
            const Offset(0, 0)),
      ),
    );
  }

  /// 更新两个选择[OverlayEntry]， 确保选区位置正确
  void markNeedsBuild([Duration? duration]) {
    if (_handles != null) {
      _handles![0].markNeedsBuild();
      _handles![1].markNeedsBuild();
    }
    toolbar?.markNeedsBuild();
  }

  ///隐藏工具栏
  void hide() {
    if (_handles != null) {
      _handles![0].remove();
      _handles![1].remove();
      _handles = null;
    }
    if (toolbar != null) {
      hideToolbar();
    }
  }

  /// 绘制两个显示句柄
  void showHandles() {
    assert(_handles == null);
    _handles = <OverlayEntry>[
      OverlayEntry(
          builder: (context) =>
              _buildHandle(context, TextSelectionHandlePosition.start)),
      OverlayEntry(
          builder: (context) =>
              _buildHandle(context, TextSelectionHandlePosition.end)),
    ];

    Overlay.of(context, rootOverlay: true, debugRequiredFor: debugRequiredFor)!
        .insertAll(_handles!);
  }

  void dispose() {
    hide();
    _toolbarController.dispose();
  }

}

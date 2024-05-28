import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:slate/slate.dart';

import '../core/cursor/cursor_controller.dart';
import '../core/floating_cursor/floating_cursor_controller.dart';
import 'editor_abstract.dart';
import '../core/box.dart';
import '../core/text/action/update_text_selection_to_adjacent_line_action.dart';
import '../core/part/text_layout_metrics_part.dart';
import '../core/part/text_position_part.dart';
import '../core/part/text_selection_part.dart';
import '../core/selection/text_selection_drag.dart';
import 'editor_builder.dart';

/// 渲染布局组件
class EditorRender extends MultiChildRenderObjectWidget {
  EditorRender({
    Key? key,
    required List<Widget> children,
    required this.node,
    required this.textDirection,
    required this.hasFocus,
    required this.selection,
    required this.startHandleLayerLink,
    required this.endHandleLayerLink,
    required this.onSelectionChanged,
    required this.onSelectionCompleted,
    required this.cursorController,
    this.padding = EdgeInsets.zero,
  }) : super(key: key, children: children);

  final Node node;
  final TextDirection textDirection;
  final bool hasFocus;
  final TextSelection selection;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final TextSelectionChangedHandler onSelectionChanged;
  final TextSelectionCompletedHandler onSelectionCompleted;
  final EdgeInsetsGeometry padding;
  final floatingCursorDisabled = false;
  final CursorController cursorController;

  @override
  EditorRenderBox createRenderObject(BuildContext context) {
    return EditorRenderBox(
      textDirection: textDirection,
      padding: padding,
      node: node,
      selection: selection,
      hasFocus: hasFocus,
      onSelectionChanged: onSelectionChanged,
      onSelectionCompleted: onSelectionCompleted,
      startHandleLayerLink: startHandleLayerLink,
      endHandleLayerLink: endHandleLayerLink,
      floatingCursorDisabled: floatingCursorDisabled,
      cursorController: cursorController,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant EditorRenderBox renderObject,
  ) {
    renderObject
      ..node = node
      ..textDirection = textDirection
      ..setHasFocus(hasFocus)
      ..setSelection(selection)
      ..setStartHandleLayerLink(startHandleLayerLink)
      ..setEndHandleLayerLink(endHandleLayerLink)
      ..onSelectionChanged = onSelectionChanged
      ..padding = padding;
  }
}

/// 渲染视图
class EditorRenderBox extends AbstractRenderLayout<RenderEditableBox> {
  EditorRenderBox({
    List<RenderEditableBox>? children,
    required TextDirection textDirection,
    required EdgeInsetsGeometry padding,
    required Node node,
    required TextSelection selection,
    required bool hasFocus,
    required CursorController cursorController,
    required this.onSelectionChanged,
    required this.onSelectionCompleted,
    required this.startHandleLayerLink,
    required this.endHandleLayerLink,
    required this.floatingCursorDisabled,
  }) : super(node) {
    initDecoration(paddingMain: padding);
    _hasFocus = hasFocus;
    _selection = selection;
    _cursorController = cursorController;
    _textSelectionPart = TextSelectionPart(this);
    _textPositionPart = TextPositionPart(this);
    _layoutMetricsPart = TextLayoutMetricsPart(this);

    _floatingCursorController = FloatingCursorController(
      cursorController: _cursorController,
      floatingCursorDisabled: floatingCursorDisabled,
      renderEditor: this,
    );
  }

  Offset get _paintOffset => Offset(0, -(offset?.pixels ?? 0.0));

  final bool floatingCursorDisabled;
  late final CursorController _cursorController;

  ViewportOffset? get offset => _offset;
  ViewportOffset? _offset;

  @override
  TextSelectionChangedHandler onSelectionChanged;
  @override
  TextSelectionCompletedHandler onSelectionCompleted;

  late TextSelectionPart _textSelectionPart;
  @override
  TextSelectionPart get textSelectionPart => _textSelectionPart;

  late TextPositionPart _textPositionPart;
  @override
  TextPositionPart get textPositionPart => _textPositionPart;

  late TextLayoutMetricsPart _layoutMetricsPart;
  @override
  TextLayoutMetricsPart get layoutMetricsPart => _layoutMetricsPart;

  @override
  FloatingCursorController get floatingCursorController =>
      _floatingCursorController;
  late FloatingCursorController _floatingCursorController;

  late bool _hasFocus = false;
  @override
  bool get hasFocus => _hasFocus;
  void setHasFocus(bool h) {
    if (hasFocus == h) {
      return;
    }
    _hasFocus = h;
    markNeedsSemanticsUpdate();
  }

  @override
  bool get readOnly => _readOnly;
  bool _readOnly = false;
  set readOnly(bool value) {
    if (_readOnly == value) {
      return;
    }
    _readOnly = value;
    markNeedsSemanticsUpdate();
  }

  late TextSelection _selection;
  @override
  TextSelection get selection => _selection;
  void setSelection(TextSelection t) {
    if (selection == t) {
      return;
    }
    _selection = t;
    markNeedsPaint();
  }

  LayerLink startHandleLayerLink;
  void setStartHandleLayerLink(LayerLink value) {
    if (startHandleLayerLink == value) {
      return;
    }
    startHandleLayerLink = value;
    markNeedsPaint();
  }

  LayerLink endHandleLayerLink;
  void setEndHandleLayerLink(LayerLink value) {
    if (endHandleLayerLink == value) {
      return;
    }
    endHandleLayerLink = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasFocus &&
        _cursorController.show.value &&
        !_cursorController.style.paintAboveText) {
      _floatingCursorController.paintFloatingCursor(context, offset);
    }
    defaultPaint(context, offset);
    // _updateSelectionExtentsVisibility(offset + _paintOffset);
    _paintHandleLayers(
        context, textSelectionPart.getEndpointsForSelection(selection));

    if (_hasFocus &&
        _cursorController.show.value &&
        _cursorController.style.paintAboveText) {
      _floatingCursorController.paintFloatingCursor(context, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  /// 绘制处理器层
  ///
  /// 传递进去文本选择的点。
  void _paintHandleLayers(
      PaintingContext context, List<TextSelectionPoint> endpoints) {
    // 开始的点
    var startPoint = endpoints[0].point;
    startPoint = Offset(
      startPoint.dx.clamp(0.0, size.width),
      startPoint.dy.clamp(0.0, size.height),
    );
    context.pushLayer(
      LeaderLayer(link: startHandleLayerLink, offset: startPoint),
      super.paint,
      Offset.zero,
    );
    if (endpoints.length == 2) {
      // 结束的点
      var endPoint = endpoints[1].point;
      endPoint = Offset(
        endPoint.dx.clamp(0.0, size.width),
        endPoint.dy.clamp(0.0, size.height),
      );
      context.pushLayer(
        LeaderLayer(link: endHandleLayerLink, offset: endPoint),
        super.paint,
        Offset.zero,
      );
    }
  }

  /// 返回 [selection] 可见的部件的 y 偏移量。
  ///
  /// 偏移量是距部件顶部的距离，是从当前滚动位置到 [selection] 变为可见的最小值。 如果 [selection] 已经可见，则返回 null。
  @override
  double? getOffsetToRevealCursor(
      double viewportHeight, double scrollOffset, double offsetInViewport) {
    final endpoints = _textSelectionPart.getEndpointsForSelection(selection);

    // when we drag the right handle, we should get the last point
    TextSelectionPoint endpoint;
    if (selection.isCollapsed) {
      endpoint = endpoints.first;
    } else {
      if (selection is TextSelectionDrag) {
        endpoint = (selection as TextSelectionDrag).first
            ? endpoints.first
            : endpoints.last;
      } else {
        endpoint = endpoints.first;
      }
    }

    final child = childAtPosition(selection.extent);
    const kMargin = 8.0;

    final caretTop = endpoint.point.dy -
        child.preferredLineHeight(TextPosition(
            offset: selection.extentOffset - child.node.blockOffset)) -
        kMargin +
        offsetInViewport;
    //   scrollBottomInset;
    final caretBottom =
        endpoint.point.dy + kMargin + offsetInViewport; // + scrollBottomInset;
    double? dy;
    if (caretTop < scrollOffset) {
      dy = caretTop;
    } else if (caretBottom > scrollOffset + viewportHeight) {
      dy = caretBottom - viewportHeight;
    }
    if (dy == null) {
      return null;
    }
    return math.max(dy, 0);
  }

  @override
  EditorVerticalCaretMovementRun startVerticalCaretMovement(
      TextPosition startPosition) {
    return EditorVerticalCaretMovementRun(
      this,
      startPosition,
    );
  }
}

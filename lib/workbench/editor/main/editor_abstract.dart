import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:slate/slate.dart';

import '../core/editor.dart';
import '../core/floating_cursor/floating_cursor_controller.dart';
import '../core/text/action/update_text_selection_to_adjacent_line_action.dart';
import '../core/part/text_layout_metrics_part.dart';
import '../core/part/text_position_part.dart';
import '../core/part/text_selection_part.dart';
import 'editor_builder.dart';

///渲染视图抽象类
abstract class AbstractEditorRenderBox<ChildType>
    extends RenderEditableContainerBox {
  AbstractEditorRenderBox(Node container) : super(node: container);

  TextSelection get selection;
  bool get hasFocus;
  bool get readOnly;
  
  TextSelectionPart get textSelectionPart;
  TextPositionPart get textPositionPart;
  TextLayoutMetricsPart get layoutMetricsPart;
  FloatingCursorController get floatingCursorController;

  /// 获取移动的偏移量来显示光标
  double? getOffsetToRevealCursor(
      double viewportHeight, double scrollOffset, double offsetInViewport);

  TextSelectionChangedHandler get onSelectionChanged;
  TextSelectionCompletedHandler get onSelectionCompleted;

  EditorVerticalCaretMovementRun startVerticalCaretMovement(
      TextPosition startPosition);
}

/// 实现文档布局
abstract class AbstractRenderLayout<ChildType>
    extends AbstractEditorRenderBox<ChildType> {
  AbstractRenderLayout(Node container) : super(container);

  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth);
    resolvePadding();
    assert(resolvedPadding != null);

    var mainAxisExtent = resolvedPadding!.top;
    var child = firstChild;
    final innerConstraints = constraints.deflate(resolvedPadding!);
    var crossAxis = 0.0;
    while (child != null) {
      child.layout(innerConstraints, parentUsesSize: true);
      final childParentData = (child.parentData! as EditableContainerParentData)
        ..offset = Offset(resolvedPadding!.left, mainAxisExtent);
      final childSize = child.size;
      mainAxisExtent += childSize.height;
      if (childSize.width > crossAxis) {
        crossAxis = childSize.width;
      }

      ComponentCache.lastSize[child.node] = child.size;
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    mainAxisExtent += resolvedPadding!.bottom;
    size = constraints.constrain(Size(crossAxis, mainAxisExtent));
    assert(size.isFinite);
  }

  double _getIntrinsicCrossAxis(double Function(RenderBox child) childSize) {
    var extent = 0.0;
    var child = firstChild;
    while (child != null) {
      extent = math.max(extent, childSize(child));
      final childParentData = child.parentData! as EditableContainerParentData;
      child = childParentData.nextSibling;
    }
    return extent;
  }

  double _getIntrinsicMainAxis(double Function(RenderBox child) childSize) {
    var extent = 0.0;
    var child = firstChild;
    while (child != null) {
      extent += childSize(child);
      final childParentData = child.parentData! as EditableContainerParentData;
      child = childParentData.nextSibling;
    }
    return extent;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    resolvePadding();
    return _getIntrinsicCrossAxis((child) {
      final childHeight = math.max<double>(
        0,
        height - resolvedPadding!.top + resolvedPadding!.bottom,
      );
      return child.getMinIntrinsicWidth(childHeight) +
          resolvedPadding!.left +
          resolvedPadding!.right;
    });
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    resolvePadding();
    return _getIntrinsicCrossAxis((child) {
      final childHeight = math.max<double>(
        0,
        height - resolvedPadding!.top + resolvedPadding!.bottom,
      );
      return child.getMaxIntrinsicWidth(childHeight) +
          resolvedPadding!.left +
          resolvedPadding!.right;
    });
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    resolvePadding();
    return _getIntrinsicMainAxis((child) {
      final childWidth = math.max<double>(
        0,
        width - resolvedPadding!.left + resolvedPadding!.right,
      );
      return child.getMinIntrinsicHeight(childWidth) +
          resolvedPadding!.top +
          resolvedPadding!.bottom;
    });
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    resolvePadding();
    return _getIntrinsicMainAxis((child) {
      final childWidth = math.max<double>(
        0,
        width - resolvedPadding!.left + resolvedPadding!.right,
      );
      return child.getMaxIntrinsicHeight(childWidth) +
          resolvedPadding!.top +
          resolvedPadding!.bottom;
    });
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    resolvePadding();
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }
}

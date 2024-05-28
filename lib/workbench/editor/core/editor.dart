import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:slate/slate.dart';

import '../mixin/default_decoration_mixin.dart';
import 'box.dart';

mixin ChildListRenderObjectMixin<ChildType extends RenderBox,
        ParentDataType extends ContainerBoxParentData<ChildType>>
    on RenderBoxContainerDefaultsMixin<ChildType, ParentDataType> {
  List<RenderBox>? _children;

  @protected
  List<RenderBox> get children {
    return _children ??= getChildrenAsList();
  }

  @protected
  @mustCallSuper
  void markNeedsChildren() {
    _children = null;
  }

  /// The number of children belonging to this render object.
  int get length => childCount;

  /// Gets the child at the specified index.
  RenderBox operator [](int index) => children[index];

  @override
  void insert(RenderBox child, {RenderBox? after}) {
    super.insert(child as ChildType, after: after as ChildType?);
    markNeedsChildren();
  }

  @override
  void remove(RenderBox child) {
    super.remove(child as ChildType);
    markNeedsChildren();
  }

  @override
  void removeAll() {
    super.removeAll();
    markNeedsChildren();
  }

  @override
  void move(RenderBox child, {RenderBox? after}) {
    super.move(child as ChildType, after: after as ChildType?);
    markNeedsChildren();
  }
}

class EditableContainerParentData
    extends ContainerBoxParentData<RenderEditableBox> {}

/// 块容器
class RenderEditableContainerBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderEditableBox,
            EditableContainerParentData>,
        RenderBoxContainerDefaultsMixin<RenderEditableBox,
            EditableContainerParentData>,
        ChildListRenderObjectMixin<RenderEditableBox,
            EditableContainerParentData>,
        EditorDecorationMixin {
  RenderEditableContainerBox({
    required Node node,
    List<RenderEditableBox>? children,
  }) {
    _node = node;
    addAll(children);
  }

  late Node _node;
  Node get node => _node;
  set node(Node c) {
    if (_node == c) {
      return;
    }
    _node = c;
    markNeedsLayout();
  }

  /// 根据文档里的文本位置，得到渲染对象
  ///
  /// [position] 里面的第一个index是当前节点在父节点里的索引
  /// 需要做判断， 检测出是否可以进入这里面，不能进入的话，说明给出来的节点位置是错误的。 这个时候需要给定一个默认的第一个节点。
  RenderEditableBox childAtPosition(TextPosition position) {
    assert(firstChild != null);

    final targetNode = _node.queryChild(position.offset, inclusive: true).node;

    // 找出符合要求的子节点
    var targetChild = firstChild;
    while (targetChild != null) {
      if (targetChild.node == targetNode) {
        break;
      }
      final newChild = childAfter(targetChild);
      if (newChild == null) {
        break;
      }
      targetChild = newChild;
    }
    if (targetChild == null) {
      throw 'targetChild should not be null';
    }
    return targetChild;
  }

  /// 根据偏移位置，得到渲染对象
  RenderEditableBox? childAtOffset(Offset offset) {
    final list = getChildrenAsList();
    RenderEditableBox? result;
    if (list.isNotEmpty) {
      for (final element in list) {
        if (element.containsOffset(offset)) {
          result = element;
          break;
        }
      }
    }
    if (result == null) {
      return null;
    }
    return result;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is EditableContainerParentData) {
      return;
    }

    child.parentData = EditableContainerParentData();
  }

  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth);
    resolvePadding();
    assert(resolvedPadding != null);

    var mainAxisExtent = resolvedPadding!.top;
    var mainCrossExtent = 0.0;
    var child = firstChild;
    // BoxConstraints.tightFor(width: constraints.maxWidth)
    final innerConstraints = constraints.deflate(resolvedPadding!);

    while (child != null) {
      child.layout(innerConstraints, parentUsesSize: true);
      final childParentData = (child.parentData! as EditableContainerParentData)
        ..offset = Offset(resolvedPadding!.left, mainAxisExtent);
      mainAxisExtent += child.size.height;

      ComponentCache.lastSize[child.node] = child.size;
      assert(child.parentData == childParentData);
      if (child.size.width > mainCrossExtent) {
        mainCrossExtent = child.size.width;
      }
      child = childParentData.nextSibling;
    }
    mainAxisExtent += resolvedPadding!.bottom;
    //size = constraints.constrain(Size(constraints.maxWidth, mainAxisExtent));
    size = constraints.constrain(Size(
        resolvedPadding!.left + mainCrossExtent + resolvedPadding!.right,
        mainAxisExtent));
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Decoration>('decoration', decoration,
        defaultValue: null));
  }
}

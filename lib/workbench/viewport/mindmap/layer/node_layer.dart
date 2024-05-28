import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:slate/slate.dart';

import '../../../../initialize.dart';
import '../../../updater/document_controller.dart';
import '../../../theme/editor_theme_styles.dart';

/// 布局数据

class MindNodeLayerData extends ParentDataWidget<MindNodeParentData> {
  const MindNodeLayerData({Key? key, required this.node, required Widget child})
      : super(key: key, child: child);

  final Node node;

  @override
  void applyParentData(RenderObject renderObject) {
    final mindmapParentData = renderObject.parentData as MindNodeParentData;
    final newKid = node.kId;
    final oldKid = mindmapParentData.node?.kId;
    if (newKid != oldKid) {
      mindmapParentData.node = node;
      final parentRenderBox = renderObject.parent as MindNodeLayerRenderBox;
      parentRenderBox.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MindNodeLayer;
}

/// 第二个层
class MindNodeLayer extends MultiChildRenderObjectWidget {
  MindNodeLayer({
    Key? key,
    List<Widget> children = const <Widget>[],
    required this.documentController,
    required this.editorThemeData,
  }) : super(key: key, children: children);

  final DocumentController documentController;
  final EditorThemeData editorThemeData;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MindNodeLayerRenderBox(
        documentController: documentController,
        editorThemeData: editorThemeData);
  }

  @override
  void updateRenderObject(
      BuildContext context, MindNodeLayerRenderBox renderObject) {
    renderObject
      ..documentController = documentController
      ..editorThemeData = editorThemeData;
  }
}

class MindNodeParentData extends ContainerBoxParentData<RenderBox> {
  /// 代理的子节点ID
   Node? node;
}

class MindNodeLayerRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MindNodeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MindNodeParentData> {
  MindNodeLayerRenderBox({
    List<RenderBox>? children,
    required DocumentController documentController,
    required EditorThemeData editorThemeData,
  })  : _documentController = documentController,
        _editorThemeData = editorThemeData {
    addAll(children);
  }

  late DocumentController _documentController;
  DocumentController get documentController => _documentController;
  set documentController(DocumentController value) {
    if (_documentController != value) {
      _documentController = value;
      markNeedsLayout();
    }
  }

  late EditorThemeData _editorThemeData;
  EditorThemeData get editorThemeData => _editorThemeData;
  set editorThemeData(EditorThemeData value) {
    if (_editorThemeData != value) {
      _editorThemeData = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    final parentData = MindNodeParentData();
    child.parentData = parentData;
  }

  @override
  performLayout() {
    final layoutBuilder = layoutBuilderInstance;
    layoutBuilder.clean();

    // 先布局孩子，设置孩子的大小
    var child = firstChild;
    if (child == null) {
      size =
          constraints.constrain(const Size(double.maxFinite, double.maxFinite));
      return;
    }
    while (child != null) {
      final childParentData = child.parentData as MindNodeParentData;
      final node = childParentData.node!;
      final themeNode = editorThemeData.nodeStyleData
          .getNodeStyleByDepth(node.nodeCache.depth!);
      // 布局出的大小

      child.layout(themeNode.constraints, parentUsesSize: true);
      final childSize = child.size;
      ComponentCache.lastSize[node] = childSize;
      final depth = node.nodeCache.depth!;
      final nodeTheme =
          editorThemeData.nodeStyleData.getNodeStyleByDepth(depth);
      final gapSize = (nodeTheme.margin.collapsedSize) / 2;
      if (child == firstChild) {
        layoutBuilder.addRoot(
          node.kId,
          node.kChildrenIds ?? [],
          node,
          childSize,
          gapSize,
          depth,
        );
      } else {
        layoutBuilder.addNode(
          node.kId,
          node.kChildrenIds,
          node,
          childSize,
          gapSize,
          depth,
        );
      }

      child = childParentData.nextSibling;
    }

    // 只有需要布局时才布局
    layoutBuilder.layout();

    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as MindNodeParentData;
      final containerNode = childParentData.node!;
      final nodeInfo = layoutBuilder.getNodeInfo(containerNode.kId);

      childParentData.offset = Offset(nodeInfo.actualX, nodeInfo.actualY);
      child = childParentData.nextSibling;
    }

    final boxRect = layoutBuilder.root!.getBoundingBox();
    size = constraints.constrain(Size(boxRect.width, boxRect.height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    return defaultHitTestChildren(result, position: position);
  }
}

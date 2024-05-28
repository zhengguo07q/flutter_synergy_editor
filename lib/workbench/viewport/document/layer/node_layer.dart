import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:slate/slate.dart';

import '../../../updater/document_controller.dart';
import '../../../theme/editor_theme_styles.dart';

class DocumentNodeLayerData extends ParentDataWidget<NodeParentData> {
  const DocumentNodeLayerData({Key? key, required this.node, required Widget child})
      : super(key: key, child: child);

  final Node node;

  @override
  void applyParentData(RenderObject renderObject) {
    final mindmapParentData = renderObject.parentData as NodeParentData;
    final newKid = node.kId;
    final oldKid = mindmapParentData.node?.kId;
    if (newKid != oldKid) {
      mindmapParentData.node = node;
      final parentRenderBox = renderObject.parent as DocumentNodeLayerRenderBox;
      parentRenderBox.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => DocumentNodeLayer;
}

/// 第二个层
class DocumentNodeLayer extends MultiChildRenderObjectWidget {
  DocumentNodeLayer({
    Key? key,
    List<Widget> children = const <Widget>[],
    required this.editorThemeData,
  }) : super(key: key, children: children);

  final EditorThemeData editorThemeData;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return DocumentNodeLayerRenderBox(
        editorThemeData: editorThemeData,
        padding: EdgeInsets.zero);
  }

  @override
  void updateRenderObject(
      BuildContext context, DocumentNodeLayerRenderBox renderObject) {
    renderObject
      ..editorThemeData = editorThemeData
      ..padding = EdgeInsets.zero;
  }
}

class NodeParentData extends ContainerBoxParentData<RenderBox> {
  Node? node;
}

class DocumentNodeLayerRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, NodeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, NodeParentData> {
  DocumentNodeLayerRenderBox({
    List<RenderBox>? children,
    required EditorThemeData editorThemeData,
    required EdgeInsetsGeometry padding,
    TextDirection? textDirection,
  })  :
        _editorThemeData = editorThemeData,
        _textDirection = textDirection,
        _padding = padding {
    addAll(children);
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
    final parentData = NodeParentData();
    child.parentData = parentData;
  }

  EdgeInsets? _resolvedPadding;

  void _resolve() {
    if (_resolvedPadding != null) {
      return;
    }
    _resolvedPadding = padding.resolve(textDirection);
    assert(_resolvedPadding!.isNonNegative);
  }

  void _markNeedResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    _markNeedResolution();
  }

  EdgeInsetsGeometry get padding => _padding;
  EdgeInsetsGeometry _padding;
  set padding(EdgeInsetsGeometry value) {
    assert(value.isNonNegative);
    if (_padding == value) {
      return;
    }
    _padding = value;
    _markNeedResolution();
  }

  @override
  performLayout() {
    final BoxConstraints constraints = this.constraints;
    _resolve();
    assert(_resolvedPadding != null);
    var child = firstChild;
    if (child == null) {
      size = constraints.constrain(Size(
        _resolvedPadding!.left + _resolvedPadding!.right,
        _resolvedPadding!.top + _resolvedPadding!.bottom,
      ));
      return;
    }

    assert(constraints.hasBoundedWidth);

    var mainAxisExtent = 0.0;
    final innerConstraints =
        BoxConstraints.tightFor(width: constraints.maxWidth)
            .deflate(_resolvedPadding!);
    while (child != null) {
      child.layout(innerConstraints, parentUsesSize: true);
      final childParentData = (child.parentData! as NodeParentData)
        ..offset = Offset(_resolvedPadding!.left, mainAxisExtent);
      mainAxisExtent += child.size.height;

      ComponentCache.lastSize[childParentData.node!] = child.size;
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    mainAxisExtent += _resolvedPadding!.bottom;
    size = constraints.constrain(Size(constraints.maxWidth, mainAxisExtent));
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

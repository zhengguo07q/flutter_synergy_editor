import 'package:flutter/material.dart';
import 'package:slate/slate.dart';
import 'package:tuple/tuple.dart';

import '../../core/box.dart';
import 'block_container.dart';

/// 承担多个孩子的渲染对象
class EditableBlock extends MultiChildRenderObjectWidget {
  EditableBlock(
      {required this.node,
      required List<Widget> children,
      required this.textDirection,
      required this.paddingMain,
      this.paddingMinor,
      this.decoration,
      Key? key})
      : super(key: key, children: children);

  final Node node;
  final TextDirection textDirection;
  final Tuple2<double, double> paddingMain;
  final EdgeInsets? paddingMinor;
  final Decoration? decoration;

  /// 上下垂直间距
  EdgeInsets get _paddingMain =>
      EdgeInsets.only(top: paddingMain.item1, bottom: paddingMain.item2);

  @override
  RenderEditableTextBlock createRenderObject(BuildContext context) {
    return RenderEditableTextBlock(
      node: node,
      textDirection: textDirection,
      paddingMain: _paddingMain,
      paddingMinor: paddingMinor,
      decoration: decoration,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderEditableTextBlock renderObject) {
    renderObject
      ..node = node
      ..textDirection = textDirection
      ..paddingMain = _paddingMain
      ..paddingMinor = paddingMinor
      ..decoration = decoration;
  }
}

class RenderEditableTextBlock extends RenderBlockContainerBox
    implements RenderEditableBox {
  RenderEditableTextBlock({
    required Node node,
    List<RenderEditableBox>? children,
    required TextDirection textDirection,
    EdgeInsetsGeometry? paddingMain,
    EdgeInsetsGeometry? paddingMinor,
    Decoration? decoration,
    Decoration? selectedDecoration,
  }) : super(
          children: children,
          node: node,
          decoration: decoration,
          selectedDecoration: selectedDecoration,
          textDirection: textDirection,
          paddingMain: paddingMain,
          paddingMinor: paddingMinor,
        );

}

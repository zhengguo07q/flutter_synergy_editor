import 'package:flutter/material.dart';

/// 主要节点主题
///
/// 普通边框
/// 选中状态

///节点有两个需要变化的东西， 一个是节点边距， 一个是节点圆角半径
class NodeStyle {
  NodeStyle({
    required this.constraints,
    required this.margin,
    required this.padding,
    required this.borderDecoration,
    required this.selectedDecoration,
  });

  /// 盒子大小
  BoxConstraints constraints;
  EdgeInsetsGeometry margin;
  EdgeInsetsGeometry padding;

  Decoration borderDecoration;
  Decoration selectedDecoration;
}

class NodeStyleData {
  NodeStyleData({
    this.nodeStyle1,
    this.nodeStyle2,
    this.nodeStyle3,
  });
  NodeStyle? nodeStyle1;
  NodeStyle? nodeStyle2;
  NodeStyle? nodeStyle3;

  NodeStyleData merge(NodeStyleData other) {
    return NodeStyleData(
      nodeStyle1: other.nodeStyle1 ?? nodeStyle1,
      nodeStyle2: other.nodeStyle2 ?? nodeStyle2,
      nodeStyle3: other.nodeStyle3 ?? nodeStyle3,
    );
  }

  static NodeStyleData getMindmap() {
    return NodeStyleData(
      nodeStyle1: NodeStyle(
        constraints: const BoxConstraints(
            minWidth: 80,
            maxWidth: 260,
            minHeight: 0,
            maxHeight: double.infinity),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        borderDecoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(5),
        ),
        selectedDecoration: BoxDecoration(
          border: Border.all(
            color: Colors.amberAccent,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      nodeStyle2: NodeStyle(
        constraints: const BoxConstraints(
            minWidth: 80,
            maxWidth: 260,
            minHeight: 0,
            maxHeight: double.infinity),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        borderDecoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(5),
        ),
        selectedDecoration: BoxDecoration(
          border: Border.all(
            color: Colors.amberAccent,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      nodeStyle3: NodeStyle(
        constraints: const BoxConstraints(
            minWidth: 80,
            maxWidth: 260,
            minHeight: 0,
            maxHeight: double.infinity),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        borderDecoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(5),
        ),
        selectedDecoration: BoxDecoration(
          border: Border.all(
            color: Colors.amberAccent,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  static NodeStyleData getDocument() {
    return NodeStyleData(
      nodeStyle1: NodeStyle(
        constraints: const BoxConstraints(
            minWidth: 80,
            maxWidth: 260,
            minHeight: 0,
            maxHeight: double.infinity),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        borderDecoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(5),
        ),
        selectedDecoration: BoxDecoration(
          border: Border.all(
            color: Colors.amberAccent,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      nodeStyle2: NodeStyle(
        constraints: const BoxConstraints(
            minWidth: 80,
            maxWidth: 260,
            minHeight: 0,
            maxHeight: double.infinity),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        borderDecoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(5),
        ),
        selectedDecoration: BoxDecoration(
          border: Border.all(
            color: Colors.amberAccent,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      nodeStyle3: NodeStyle(
        constraints: const BoxConstraints(
            minWidth: 80,
            maxWidth: 260,
            minHeight: 0,
            maxHeight: double.infinity),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        borderDecoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(5),
        ),
        selectedDecoration: BoxDecoration(
          border: Border.all(
            color: Colors.amberAccent,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  NodeStyle getNodeStyleByDepth(int depth) {
    if (depth == 1) {
      return nodeStyle1!;
    } else if (depth == 2) {
      return nodeStyle2!;
    } else {
      return nodeStyle3!;
    }
  }
}
//
// extension NodeThemeExtension on NodeStyle {
//   BoxDecoration getBorderDecoration(int depth) {
//     return BoxDecoration(
//       color: Colors.amber,
//       borderRadius: BorderRadius.circular(5),
//     );
//   }
//
//   BoxDecoration getSelectedDecoration() {
//     return BoxDecoration(
//       color: Colors.amber,
//       borderRadius: BorderRadius.circular(5),
//     );
//   }
//
//   EdgeInsets? getComputePadding(int depth) {
//     var thisTheme = this as dynamic;
//     EdgeInsets? resultPadding;
//     if (depth == 1) {
//       resultPadding = thisTheme.padding!.add(thisTheme.extensionPaddingLevel1);
//     } else if (depth == 2) {
//       resultPadding = thisTheme.padding!.add(thisTheme.extensionPaddingLevel2);
//     } else {
//       resultPadding = thisTheme.padding;
//     }
//     return resultPadding;
//   }
//
//   NodeTheme getNodeThemeByDepth(int depth) {
//     var thisTheme = this;
//     if (depth == 1) {
//       return thisTheme.copyWith(
//         radius: thisTheme.radius! + thisTheme.extensionRadiusLevel1,
//         padding: thisTheme.padding!.add(thisTheme.extensionPaddingLevel1),
//       );
//     } else if (depth == 2) {
//       return thisTheme.copyWith(
//         radius: thisTheme.radius! + thisTheme.extensionRadiusLevel2,
//         padding: thisTheme.padding!.add(thisTheme.extensionPaddingLevel2),
//       );
//     } else {
//       return this;
//     }
//   }
// }

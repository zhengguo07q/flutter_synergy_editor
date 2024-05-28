import 'dart:math';

import 'package:thinkhub_client/workbench/layout/algorithm/tidy_tree/tidy_tree_data.dart';
import 'package:thinkhub_client/workbench/layout/layout_builder.dart';

class AlgorithmUtil {
  static void moveRight(NodeData node, double move, bool isHorizontal) {
    if (isHorizontal) {
      node.y += move;
    } else {
      node.x += move;
    }
    for (final child in node.children) {
      AlgorithmUtil.moveRight(child, move, isHorizontal);
    }
  }

  static double getMin(NodeData node, bool isHorizontal) {
    var res = isHorizontal ? node.y : node.x;
    for (final child in node.children) {
      res = min(AlgorithmUtil.getMin(child, isHorizontal), res);
    }

    return res;
  }

  static void normalize(NodeData node, bool isHorizontal) {
    final min = AlgorithmUtil.getMin(node, isHorizontal);
    AlgorithmUtil.moveRight(node, -min, isHorizontal);
  }

  static void convertBack(
    TidyTreeData converted,
    NodeData root,
    bool isHorizontal,
  ) {
    if (isHorizontal) {
      root.y = converted.x;
    } else {
      root.x = converted.x;
    }
    converted.c.asMap().forEach((i, child) {
      AlgorithmUtil.convertBack(child, root.children[i], isHorizontal);
    });
  }

  static void layer(NodeData node, bool isHorizontal, {double d = 0}) {
    if (isHorizontal) {
      node.x = d;
      d += node.width;
    } else {
      node.y = d;
      d += node.height;
    }
    for (final child in node.children) {
      AlgorithmUtil.layer(child, isHorizontal, d: d);
    }
  }
}

import 'package:thinkhub_client/workbench/layout/algorithm/tidy_tree/tidy_tree_algorithms.dart';
import 'package:thinkhub_client/workbench/layout/layout_builder.dart';

abstract class LayoutExecution{
  LayoutExecution(this.algorithm, this.layoutConfig);
  final Algorithm algorithm;
  final LayoutConfig layoutConfig;

  NodeData doLayout(NodeData root);
}

class DownwardLayout extends LayoutExecution {
  DownwardLayout() : super(TidyTreeAlgorithms(), LayoutConfig(false));

  @override
  NodeData doLayout(NodeData root) {
    return algorithm.run(root, false);
  }
}

class LeftLayout extends LayoutExecution {
  LeftLayout() : super(TidyTreeAlgorithms(), LayoutConfig(true));

  @override
  NodeData doLayout(NodeData root) {
    algorithm.run(root, true);
    root.right2left();
    return root;
  }
}

class RightLayout extends LayoutExecution {
  RightLayout() : super(TidyTreeAlgorithms(), LayoutConfig(true));

  @override
  NodeData doLayout(NodeData root) {
    return algorithm.run(root, true);
  }
}

class UpwardLayout extends LayoutExecution {
  UpwardLayout() : super(TidyTreeAlgorithms(), LayoutConfig(false));

  @override
  NodeData doLayout(NodeData root) {
    algorithm.run(root, false);
    root.down2up();
    return root;
  }
}

class StandardLayout extends LayoutExecution {
  StandardLayout() : super(TidyTreeAlgorithms(), LayoutConfig(true));

  @override
  NodeData doLayout(NodeData root) {
    // 把第一级下面的子节点分散到两棵树中
    final leftTree = root;
    final rightTree = root;
    final treeSize = root.children.length;
    final rightTreeSize = treeSize ~/ 2;
    for (var i = 0; i < treeSize; i++) {
      final child = root.children[i];
      if (i < rightTreeSize) {
        rightTree.children.add(child);
      } else {
        leftTree.children.add(child);
      }
    }
    // 做两棵树的布局
    algorithm
      ..run(rightTree, true)
      ..run(leftTree, true);
    leftTree.right2left();
    // 右侧的树平移
    rightTree.translate(leftTree.x - rightTree.x, leftTree.y - rightTree.y);
    // translate root
    root
      ..x = leftTree.x
      ..y = rightTree.y;
    final bb = root.getBoundingBox();
    if (bb.top < 0) {
      root.translate(0, -bb.top);
    }
    return root;
  }
}

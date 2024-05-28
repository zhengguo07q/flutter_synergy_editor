import 'package:thinkhub_client/workbench/layout/layout_builder.dart';

class TidyTreeData {
  TidyTreeData(this.w, this.h, this.y, this.c) : cs = c.length;

  factory TidyTreeData.fromNode(NodeData nodeData, bool isHorizontal) {
    final trees = <TidyTreeData>[];
    for (final child in nodeData.children) {
      trees.add(TidyTreeData.fromNode(child, isHorizontal));
    }
    if (isHorizontal) {
      return TidyTreeData(nodeData.height, nodeData.width, nodeData.x, trees);
    }
    return TidyTreeData(nodeData.width, nodeData.height, nodeData.y, trees);
  }

  // 宽，高，位置
  double w = 0;
  double h = 0;
  double x = 0;
  double y = 0;

  double prelim = 0;
  double mod = 0;
  double shift = 0;
  double change = 0;

  // 左孩子分支和右孩子分支.
  TidyTreeData? tl;
  TidyTreeData? tr;

  // 相邻的左和右侧节点
  TidyTreeData? el;
  TidyTreeData? er;

  // Sum of modifiers at the extreme nodes.
  // 相邻节点的
  double msel = 0;
  double mser = 0;

  // 子节点数组和子节点数量
  List<TidyTreeData> c = [];
  int cs = 0;
}

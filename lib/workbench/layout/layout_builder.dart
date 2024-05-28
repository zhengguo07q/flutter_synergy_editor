import 'dart:collection';
import 'dart:math';

import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:slate/slate.dart' hide Point;
import 'package:thinkhub_client/workbench/layout/category/tidy_tree_layout.dart';
import 'package:thinkhub_client/workbench/layout/layout_info.dart';

enum LayoutType { standard, right, left, upward, downward, doc }

enum LayoutOrientation { left, top, right, bottom }

class BoxRect {
  BoxRect({this.left = 0, this.top = 0, this.width = 0, this.height = 0});

  double left;
  double top;
  double width;
  double height;
}

class NodeData {
  NodeData(
      this.id, this.childrenIds, this.node, this.depth, Size size, Size gap) {
    width = size.width;
    height = size.height;
    addGap(gap.width, gap.height);
  }

  final String id;
  double hGap = 0;
  double vGap = 0;
  double x = 0;
  double y = 0;
  double width = 0;
  double height = 0;
  int depth = 0;
  NodeData? parent;

  // 子节点
  List<NodeData> children = [];

  //子节点ID
  List<String>? childrenIds = [];

  Node node;
  bool showBBox = false;
  bool isTemp = false;
  BoxRect bBox = BoxRect();
  static bool isCreateComplete = false;

  /// 添加水平间距和垂直
  void addGap(double hGap, double vGap) {
    this.hGap += hGap;
    this.vGap += vGap;
    width += 2 * hGap;
    height += 2 * vGap;
  }

  /// 判断是否为根节点
  bool isRoot() {
    return depth == 0;
  }

  /// 对所有的节点执行回调函数
  void eachNode(void Function(NodeData) callback) {
    final nodes = <NodeData>[this];
    NodeData? current = nodes.removeLast();
    while (current != null) {
      callback(current);
      nodes.addAll(current.children);

      current = null;
      if (nodes.isNotEmpty) {
        current = nodes.removeLast();
      }
    }
  }

  /// 得到执行节点的bb盒子
  BoxRect getBoundingBox() {
    final bb = BoxRect(left: double.maxFinite, top: double.maxFinite);
    eachNode((NodeData node) {
      bb
        ..left = min(bb.left, node.x)
        ..top = min(bb.top, node.y)
        ..width = max(bb.width, node.x + node.width)
        ..height = max(bb.height, node.y + node.height);
    });
    if (NodeData.isCreateComplete) {
      bBox = bb;
    }
    return bb;
  }

  /// 对执行对节点包含子节点执行平移
  void translate(double tx, double ty) {
    eachNode((NodeData node) {
      node
        ..x += tx
        ..y += ty;
    });
  }

  /// 计算执行的节点的bb盒子，并且向左平移
  void right2left() {
    final bb = getBoundingBox();
    eachNode((NodeData nodep) {
      final node = nodep;
      node.x = node.x - (node.x - bb.left) * 2 - node.width;
    });
    translate(bb.width, 0);
  }

  /// 计算执行的节点的bb盒子，并且向上平移
  void down2up() {
    final bb = getBoundingBox();
    eachNode((NodeData node) {
      node.y = node.y - (node.y - bb.top) * 2 - node.height;
    });
    translate(0, bb.height);
  }

  /// 得到命中节点, 有待优化
  NodeData? getHit(Point p) {
    NodeData? hitNode;
    eachNode((NodeData node) {
      if (!node.isTemp && node.isHit(p)) {
        hitNode = node;
      }
    });
    return hitNode;
  }

  double getSubPosition(Point p) {
    var pos = 0.0;
    for (final nodeData in children) {
      final bBox = nodeData.getBoundingBox();
      final heightLine = (bBox.top + bBox.height) / 2;
      if (p.x > heightLine) {
        pos += 1;
      }
    }
    return pos;
  }

  /// 检测命中
  bool isHit(Point p) {
    final box = getBoundingBox();
    if (p.x > (box.left) &&
        p.x < (box.width) &&
        p.y > (box.top) &&
        p.y < (box.height)) {
      return true;
    }
    return false;
  }
}

abstract class Algorithm {
  NodeData run(NodeData root, bool isHorizontal);
}

class LayoutConfig {
  LayoutConfig(this.isHorizontal);

  final bool isHorizontal;
}

class LayoutBuilder extends ChangeNotifier {
  LayoutBuilder() {
    setLayoutType(LayoutType.right);
  }

  static Map<String, NodeData> computeNodeCaches = {};
  final Map<String, NodeInfo> nodes = {};

  NodeData? root;
  late LayoutExecution layoutExecution;

  NodeData? getRoot() {
    return root;
  }

  NodeInfo getNodeInfo(String id) {
    assert(nodes.containsKey(id), 'node info map must container this id, $id');
    return nodes[id]!;
  }

  void setLayoutType(LayoutType layoutType) {
    switch (layoutType) {
      case LayoutType.left:
        layoutExecution = LeftLayout();
        break;
      case LayoutType.right:
        layoutExecution = RightLayout();
        break;
      case LayoutType.upward:
        layoutExecution = UpwardLayout();
        break;
      case LayoutType.downward:
        layoutExecution = DownwardLayout();
        break;
      case LayoutType.standard:
      default:
        layoutExecution = StandardLayout();
    }
  }

  NodeData doLayout() {
    return layoutExecution.doLayout(root!);
  }

  NodeData addRoot(
    String id,
    List<String> ids,
    Node node,
    Size size,
    Size gap,
    int depth,
  ) {
    return root = addNode(id, ids, node, size, gap, depth);
  }

  NodeData addNode(
    String id,
    List<String>? ids,
    Node node,
    Size size,
    Size gap,
    int depth,
  ) {
    final nodeData = NodeData(id, ids, node, depth, size, gap);
    computeNodeCaches[id] = nodeData;

    return nodeData;
  }

  void layout() {
    AppLogger.appLog.i('computeNodeCaches$computeNodeCaches');
    _organizationNode();
    doLayout();
    cacheNodeInfo();
    notifyListeners();
  }

  void clean() {
    computeNodeCaches.clear();
    nodes.clear();
    root = null;
  }

  void _organizationNode() {
    if (root == null) {
      return;
    }
    final opList = Queue<NodeData>()..addLast(root!);
    while (opList.isNotEmpty) {
      final nextNode = opList.removeFirst();
      if (nextNode.childrenIds != null) {
        for (final id in nextNode.childrenIds!) {
          if (computeNodeCaches.containsKey(id)) {
            final child = computeNodeCaches[id]!;
            nextNode.children.add(child);
            opList.addLast(child);
          }
        }
      }
    }
  }

  // /// 计算子节点的方向，方向是可以继承的，主要是为了在子节点隐藏时，知道方向
  // LayoutOrientation calculateOrientation(
  //     LayoutNode parentNode, LayoutNode childNode, bool isHorizontal) {
  //   var retOrientation;
  //   final beginNode = parentNode;
  //   final endNode = childNode;
  //   // 算出位置方向
  //   if (isHorizontal) {
  //     // 水平
  //     if (beginNode.x > endNode.x) {
  //       // 根在右边， 交换位置
  //       retOrientation = LayoutOrientation.LEFT;
  //     } else {
  //       retOrientation = LayoutOrientation.RIGHT;
  //     }
  //   } else {
  //     // 垂直
  //     if (beginNode.y > endNode.y) {
  //       // 根在下面，交换位置
  //       retOrientation = LayoutOrientation.TOP;
  //     } else {
  //       retOrientation = LayoutOrientation.BOTTOM;
  //     }
  //   }
  //   return retOrientation;
  // }

  /// 获得布局后数据
  void cacheNodeInfo() {
    if (root == null) {
      return;
    }
    root!.eachNode((NodeData node) {
      final nodeData = NodeInfo()
        ..node = node.node
        ..id = node.id
        // position
        ..x = node.x
        ..y = node.y
        ..actualX = node.x + node.hGap
        ..actualY = node.y + node.vGap
        ..centX = node.x + node.width / 2
        ..centY = node.y + node.height / 2
        // size
        ..hGap = node.hGap
        ..vGap = node.vGap
        ..height = node.height
        ..width = node.width
        ..actualHeight = node.height - node.vGap * 2
        ..actualWidth = node.width - node.hGap * 2
        // depth
        ..depth = node.depth;

      nodes[node.id] = nodeData;
    });
  }

  /// 获取边缘关系，获取每个对象和它所拥有的子对象的父子关系连接
  List<EdgeInfo> getEdges() {
    final edges = <EdgeInfo>[];
    if (root == null) {
      return edges;
    }
    root!.eachNode((NodeData node) {
      for (final child in node.children) {
        edges.add(EdgeInfo(node.id, child.id));
      }
    });
    return edges;
  }
}

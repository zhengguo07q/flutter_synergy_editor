import 'package:flutter/painting.dart';

import '../../layout/layout_info.dart';
import '../line_style.dart';

class ConnectionInfo {
  const ConnectionInfo(
      this.beginNode, this.beginOffset, this.endNode, this.endOffset);

  final NodeInfo beginNode;
  final Offset beginOffset;
  final NodeInfo endNode;
  final Offset endOffset;
}

class LineUtil{
  static ConnectionInfo computeLinePosition(
      LineStyle lineStyle,
      NodeInfo sourceNode,
      NodeInfo targetNode,
      bool isHorizontal,
      ) {
    var beginNode = sourceNode;
    var endNode = targetNode;
    var beginX = 0.0, beginY = 0.0, endX = 0.0, endY = 0.0;

    if (isHorizontal) {
      // 水平布局
      // 向右布局， 根节点在右侧
      if (sourceNode.x > targetNode.x) {
        beginNode = targetNode;
        endNode = sourceNode;
      }

      beginX = beginNode.x + beginNode.width - beginNode.hGap;
      if (lineStyle.beginPosType == LinePositionType.axisCenter) {
        beginY = beginNode.y + beginNode.height / 2;
      } else if (lineStyle.beginPosType == LinePositionType.baselineCenter) {
        beginY = beginNode.y + beginNode.height - beginNode.vGap; // 要去掉一个gap
      }

      endX = endNode.x + endNode.hGap;
      if (lineStyle.endPosType == LinePositionType.axisCenter) {
        endY = endNode.y + endNode.height / 2;
      } else if (lineStyle.endPosType == LinePositionType.baselineCenter) {
        endY = endNode.y + endNode.height - endNode.vGap;
      }
    } else {
      // 垂直布局
      if (beginNode.y > endNode.y) {
        // 根在下面，交换位置
        beginNode = targetNode;
        endNode = sourceNode;
      }

      beginX = beginNode.x + beginNode.width / 2;
      beginY = beginNode.y + beginNode.height - beginNode.vGap;

      endX = endNode.x + endNode.width / 2;
      endY = endNode.y + endNode.vGap;
    }
    // 是根节点，则连接点在中间
    if (lineStyle.beginPosType == LinePositionType.nodeCenter) {
      beginX = beginNode.x + beginNode.width / 2;
      beginY = beginNode.y + beginNode.height / 2;
    }
    if (lineStyle.endPosType == LinePositionType.nodeCenter) {
      endX = endNode.x + endNode.width / 2;
      endY = endNode.y + endNode.height / 2;
    }

    return ConnectionInfo(
        beginNode, Offset(beginX, beginY), endNode, Offset(endX, endY));
  }
}

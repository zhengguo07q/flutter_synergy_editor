import 'package:flutter/material.dart' hide LayoutBuilder;
import 'package:thinkhub_client/workbench/layout/layout_builder.dart';
import 'package:thinkhub_client/workbench/layout/layout_info.dart';
import 'package:thinkhub_client/workbench/theme/paint/line_paint.dart';

typedef PaintFunc = void Function({
  required Canvas canvas,
  required LineStyle lineStyle,
  required LayoutBuilder layoutBuilder,
  required NodeInfo sourceNodeInfo,
  required NodeInfo targetNodeInfo,
});

enum LinePositionType {
  none, // 不存在链接，根节点不能为目标节点
  nodeCenter, //坐标轴的正中央，一般用于根节点
  axisCenter, //轴线居中
  baselineCenter, //基线居中
}

class LineStyle {
  const LineStyle({
    this.beginPosType,
    this.endPosType,
    this.hasUnderline,
    this.strokeWidth,
    this.lineColor,
    this.lineRadius,
    this.collapsedOffset,
    this.paintFunc,
  });

  final LinePositionType? beginPosType;
  final LinePositionType? endPosType;
  final bool? hasUnderline; // 是否有下划线
  final double? strokeWidth; // 行宽
  final Color? lineColor;
  final double? lineRadius;
  final int? collapsedOffset;
  final PaintFunc? paintFunc;

  LineStyle merge(LineStyle other) {
    return LineStyle(
      beginPosType: other.beginPosType ?? beginPosType,
      endPosType: other.endPosType ?? endPosType,
      hasUnderline: other.hasUnderline ?? hasUnderline,
      strokeWidth: other.strokeWidth ?? strokeWidth,
      lineColor: other.lineColor ?? lineColor,
      lineRadius: other.lineRadius ?? lineRadius,
      collapsedOffset: other.collapsedOffset ?? collapsedOffset,
      paintFunc: other.paintFunc ?? paintFunc,
    );
  }

  @override
  int get hashCode {
    return hashValues(
      beginPosType,
      endPosType,
      hasUnderline,
      strokeWidth,
      lineColor,
      lineRadius,
      collapsedOffset,
      paintFunc,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LineStyle &&
        other.beginPosType == beginPosType &&
        other.endPosType == endPosType &&
        other.hasUnderline == hasUnderline &&
        other.strokeWidth == strokeWidth &&
        other.lineColor == lineColor &&
        other.lineRadius == lineRadius &&
        other.collapsedOffset == collapsedOffset &&
        other.paintFunc == paintFunc;
  }
}

class LineStyleData {
  LineStyleData({
    this.lineStyle1,
    this.lineStyle2,
    this.lineStyle3,
  });
  LineStyle? lineStyle1;
  LineStyle? lineStyle2;
  LineStyle? lineStyle3;

  LineStyle getLineStyleByDepth(int depth) {
    if (depth == 1) {
      return lineStyle1!;
    } else if (depth == 2) {
      return lineStyle2!;
    } else {
      return lineStyle3!;
    }
  }

  LineStyleData merge(LineStyleData other) {
    return LineStyleData(
      lineStyle1: other.lineStyle1 ?? lineStyle1,
      lineStyle2: other.lineStyle2 ?? lineStyle2,
      lineStyle3: other.lineStyle3 ?? lineStyle3,
    );
  }

  static LineStyleData getInstance() {
    return LineStyleData(
      lineStyle1: const LineStyle(
        beginPosType: LinePositionType.nodeCenter,
        endPosType: LinePositionType.axisCenter,
        hasUnderline: true,
        strokeWidth: 1,
        lineColor: Colors.grey,
        lineRadius: 1,
        collapsedOffset: 0,
        paintFunc: paintLine,
      ),
      lineStyle2: const LineStyle(
        beginPosType: LinePositionType.axisCenter,
        endPosType: LinePositionType.axisCenter,
        hasUnderline: true,
        strokeWidth: 1,
        lineColor: Colors.grey,
        lineRadius: 1,
        collapsedOffset: 0,
        paintFunc: paintLine,
      ),
      lineStyle3: const LineStyle(
        beginPosType: LinePositionType.axisCenter,
        endPosType: LinePositionType.axisCenter,
        hasUnderline: true,
        strokeWidth: 1,
        lineColor: Colors.grey,
        lineRadius: 1,
        collapsedOffset: 0,
        paintFunc: paintLine,
      ),
    );
  }
}

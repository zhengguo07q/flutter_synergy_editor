import 'package:flutter/painting.dart';
import 'package:thinkhub_client/workbench/layout/layout_builder.dart';
import 'package:thinkhub_client/workbench/layout/layout_info.dart';
import 'package:thinkhub_client/workbench/theme/line_style.dart';
import 'package:thinkhub_client/workbench/theme/paint/line_util.dart';

void paintLine({
  required Canvas canvas,
  required LineStyle lineStyle,
  required LayoutBuilder layoutBuilder,
  required NodeInfo sourceNodeInfo,
  required NodeInfo targetNodeInfo,
}) {
  final paint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = lineStyle.strokeWidth!
    ..strokeCap = StrokeCap.round
    ..color = lineStyle.lineColor!
    ..style = PaintingStyle.stroke;

  final path = Path();
  final isHorizontal = layoutBuilder.layoutExecution.layoutConfig.isHorizontal;
  final lineData = LineUtil.computeLinePosition(
    lineStyle,
    sourceNodeInfo,
    targetNodeInfo,
    isHorizontal,
  );

  final beginNode = lineData.beginNode;
  final beginOffset = lineData.beginOffset;
  final endNode = lineData.endNode;
  final endOffset = lineData.endOffset;

  path.moveTo(beginOffset.dx, beginOffset.dy);

  if (isHorizontal) {
    path.relativeCubicTo(
      beginOffset.dx + (beginNode.hGap + endNode.hGap) / 2 - beginOffset.dx,
      beginOffset.dy - beginOffset.dy,
      endOffset.dx - (beginNode.hGap + endNode.hGap) / 2 - beginOffset.dx,
      endOffset.dy - beginOffset.dy,
      endOffset.dx - beginOffset.dx,
      endOffset.dy - beginOffset.dy,
    );
  } else {
    path.relativeCubicTo(
      beginOffset.dx - beginOffset.dx,
      beginOffset.dy + (beginNode.vGap + endNode.vGap) / 2 - beginOffset.dy,
      endOffset.dx - beginOffset.dx,
      endOffset.dy - (beginNode.vGap + endNode.vGap) / 2 - beginOffset.dy,
      endOffset.dx - beginOffset.dx,
      endOffset.dy - beginOffset.dy,
    );
  }
  canvas.drawPath(path, paint);
}

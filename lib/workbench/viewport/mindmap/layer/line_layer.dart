import 'package:flutter/widgets.dart' hide LayoutBuilder;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/initialize.dart';
import 'package:thinkhub_client/workbench/updater/document_controller.dart';

import '../../../layout/layout_builder.dart';
import '../../../layout/layout_info.dart';
import '../../../theme/editor_theme_styles.dart';
import '../../../theme/line_style.dart';

class LineRenderStyle {
  LineRenderStyle(Node node) {
    shape = node.getAttribute(AttributeRegister.mindThemeLineShape.key,
        defaultValue: AttributeRegister.mindThemeLineShape);
    style = node.getAttribute(AttributeRegister.mindThemeLineStyle.key,
        defaultValue: AttributeRegister.mindThemeLineStyle);
    endPoint = node.getAttribute(AttributeRegister.mindThemeLineEndPoint.key,
        defaultValue: AttributeRegister.mindThemeLineEndPoint);
    width = node.getAttribute(AttributeRegister.mindThemeLineWidth.key,
        defaultValue: AttributeRegister.mindThemeLineWidth);
    color = node.getAttribute(AttributeRegister.mindThemeLineColor.key,
        defaultValue: AttributeRegister.mindThemeLineColor);
  }
  late Attribute shape;
  late Attribute style;
  late Attribute endPoint;
  late Attribute width;
  late Attribute color;

  LineStyle getLineStyle() {
    return const LineStyle();
  }
}


class LineLayer extends ConsumerStatefulWidget {
  const LineLayer({Key? key, required this.documentController})
      : super(key: key);
  final DocumentController documentController;
  @override
  ConsumerState<LineLayer> createState() => _LineLayerState();
}

class _LineLayerState extends ConsumerState<LineLayer> {

  @override
  initState(){
    layoutBuilderInstance.addListener(onLayoutUpdate);
    super.initState();
  }

  void onLayoutUpdate(){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(mounted){
        setState((){});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lineStyleData = ref.watch(nodeThemeProvider).lineStyleData;
    final layoutBuilder = layoutBuilderInstance;
    final edgeInfoList = layoutBuilder.getEdges();

    final children = <Widget>[];
    for (final edgeInfo in edgeInfoList) {
      final sourceNodeInfo = layoutBuilder.getNodeInfo(edgeInfo.sourceId);
      final targetNodeInfo = layoutBuilder.getNodeInfo(edgeInfo.targetId);
      final lineRenderStyle = LineRenderStyle(sourceNodeInfo.node);
      final defaultLineStyle =
          lineStyleData.getLineStyleByDepth(sourceNodeInfo.depth);
      final mergeLineStyle =
          defaultLineStyle.merge(lineRenderStyle.getLineStyle());
      children.add(CustomPaint(
        painter: LinePainter(
          mergeLineStyle,
          layoutBuilder,
          sourceNodeInfo,
          targetNodeInfo,
        ),
      ));
    }
    return Stack(children: children);
  }

  @override
  void dispose(){
    layoutBuilderInstance.removeListener(onLayoutUpdate);
    super.dispose();
  }
}

/// 绘制线条
class LinePainter extends CustomPainter {
  LinePainter(this.lineStyle, this.layoutBuilder, this.sourceNodeInfo,
      this.targetNodeInfo);
  final LineStyle lineStyle;
  final LayoutBuilder layoutBuilder;
  final NodeInfo sourceNodeInfo;
  final NodeInfo targetNodeInfo;
  @override
  void paint(Canvas canvas, Size size) {
    lineStyle.paintFunc!(
      canvas: canvas,
      lineStyle: lineStyle,
      layoutBuilder: layoutBuilder,
      sourceNodeInfo: sourceNodeInfo,
      targetNodeInfo: targetNodeInfo,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

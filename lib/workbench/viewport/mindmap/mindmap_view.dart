import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keframe/keframe.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/initialize.dart';

import '../../updater/document_controller.dart';
import '../../extension/_builder.dart';
import '../../theme/editor_theme_styles.dart';
import 'layer/line_layer.dart';
import 'layer/node_layer.dart';

class MindMapView extends StatefulWidget {
  const MindMapView({Key? key}) : super(key: key);
  @override
  State<MindMapView> createState() => _MindMapViewState();
}

class _MindMapViewState extends State<MindMapView> {
  late TransformationController transformationController;
  late DocumentController documentController;

  @override
  void initState() {
    transformationController = TransformationController();
    documentController = documentControllerInstance;
    documentController.dirtyUpdater.addListener(onDocumentDirtyUpdate);
    super.initState();
  }

  void onDocumentDirtyUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      return InteractiveViewer(
        constrained: false,
        transformationController: transformationController,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Center(
            child: SizeCacheWidget(
              child: MindMapLayout(
                documentController: documentController,
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    documentController.dirtyUpdater.removeListener(onDocumentDirtyUpdate);
    super.dispose();
  }
}

class MindMapLayout extends ConsumerStatefulWidget {
  const MindMapLayout({
    Key? key,
    required this.documentController,
  }) : super(key: key);
  final DocumentController documentController;

  @override
  ConsumerState<MindMapLayout> createState() => _MindMapLayoutState();
}

class _MindMapLayoutState extends ConsumerState<MindMapLayout> {
  List<Widget> buildNodeDataWidgetList(List<Node> nodeList) {
    final nodeDataWidgetList = <MindNodeLayerData>[];
    final nodeWidget = BlockBuilder.buildElementList(widget.documentController);
    nodeWidget.forEachIndexed((nodeWidget, index) {
      final nodeDataWidget = MindNodeLayerData(
        node: nodeList[index],
        child: nodeWidget,
      );
      nodeDataWidgetList.add(nodeDataWidget);
    });
    return nodeDataWidgetList;
  }

  @override
  Widget build(BuildContext context) {
    final nodeThemeNotifier = ref.watch(nodeThemeProvider);

    return Stack(
      fit: StackFit.loose,
      children: [
        FrameSeparateWidget(
          child: LineLayer(
            documentController: widget.documentController,
          ),
        ),
        MindNodeLayer(
          children: buildNodeDataWidgetList(
              widget.documentController.document.children),
          documentController: widget.documentController,
          editorThemeData: nodeThemeNotifier,
        ),
      ],
    );
  }
}

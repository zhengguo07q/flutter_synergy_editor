import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slate/slate.dart';

import '../../../initialize.dart';
import '../../updater/document_controller.dart';
import '../../extension/_builder.dart';
import '../../theme/editor_theme_styles.dart';
import 'layer/node_layer.dart';

class DocumentView extends StatefulWidget {
  const DocumentView({Key? key}) : super(key: key);

  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  late TransformationController transformationController;
  late DocumentController documentController;
  @override
  void initState() {
    transformationController = TransformationController();
    documentController = documentControllerInstance;
    documentController.addListener(onDocumentDirtyUpdate);
    super.initState();
  }

  void onDocumentDirtyUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final renderBox = context.findRenderObject() as RenderBox;
        final offset = renderBox.localToGlobal(Offset.zero);
        return DocumentLayout(
          documentController: documentController,
        );
      }
    );
  }

  @override
  dispose(){
    documentController.removeListener(onDocumentDirtyUpdate);
    super.dispose();
  }
}

class DocumentLayout extends ConsumerStatefulWidget {
  const DocumentLayout({
    Key? key,
    required this.documentController,
  }) : super(key: key);
  final DocumentController documentController;

  @override
  ConsumerState<DocumentLayout> createState() => _DocumentLayoutState();
}

class _DocumentLayoutState extends ConsumerState<DocumentLayout> {
  List<Widget> buildNodeDataWidgetList(List<Node> nodeList) {
    final nodeDataWidgetList = <DocumentNodeLayerData>[];
    final nodeWidget = BlockBuilder.buildElementList(widget.documentController);
    nodeWidget.forEachIndexed((nodeWidget, index) {
      final nodeDataWidget = DocumentNodeLayerData(
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
    return DocumentNodeLayer(
      children:
          buildNodeDataWidgetList(widget.documentController.document.children),
      editorThemeData: nodeThemeNotifier,
    );
  }
}

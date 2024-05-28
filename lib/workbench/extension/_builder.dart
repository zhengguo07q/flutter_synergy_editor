import 'package:crdt/crdt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/extension/single/single_block.dart';

import '../updater/document_controller.dart';

class BlockType {
  static const String table = 'table';
  static const String step = 'step';
  static const String stepItem = 'stepItem';
  static const String singleLine = 'single';
  static const String timeline = 'timeline';
  static const String timelineItem = 'timelineItem';
  static const String wordExplain = 'wordExplain';
}

class BlockBuilder {
  /// 构建子对象，可编辑的块
  static List<Widget> buildElementList(
    DocumentController controller,
  ) {
    final result = <Widget>[];
    var index = 0;
    for (final node in controller.document.children) {
      Widget? child = createWidget(
        node: node,
        index: index,
        controller: controller,
      );
      child = Draggable<Node>(
        data: node,
        feedback: LayoutBuilder(builder: (context, constraints) {
          final saveSize =
              ComponentCache.lastSize.get(node) ?? const Size(100, 100);
          return SizedBox(
            width: saveSize.width,
            height: saveSize.height,
            child: createWidget(node: node, index: -1, controller: controller),
          );
        }),
        dragAnchorStrategy: childDragAnchorStrategy,
        //childWhenDragging: widget,
        onDragStarted: () {
          print("onDragStarted");
        },
        onDragEnd: (DraggableDetails details) {
          print("onDragEnd : $details");
        },
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          print('onDraggableCanceled velocity:$velocity,offset:$offset');
        },
        onDragCompleted: () {
          print('onDragCompleted');
        },
        child: child,
      );
      index++;
      result.add(child);
    }
    return result;
  }

  static Widget createWidget({
    required Node node,
    required int index,
    required DocumentController controller,
  }) {
    Widget? child;
    Key? key;
    // if (index >= 0) {
    //   key = mapNavigatorKeyList.elementAt(index);
    // }
    switch (node.type) {
      case BlockType.singleLine:
        child = SingleBlock(
          key: key,
          controller: controller,
          parentPath: Path.of([index]),
          node: node,
          // cursorCont: cursorCont,
          // hasFocus: hasFocus,
          // enableInteractiveSelection: enableInteractiveSelection,
          // textDirection: textDirection,
          // selectionColor: selectionColor,
          // textSelection: textSelection,
          // stylesData: textStylesData,
          // readOnly: readOnly,
          // controller: controller,
        );
        break;
      default:
        throw ArgumentError('create extension error : $node');
    }
    return child;
  }
}

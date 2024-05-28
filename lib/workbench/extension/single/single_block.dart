import 'package:common/common.dart';
import 'package:flutter/material.dart' hide Path;
import 'package:flutter/widgets.dart' hide Path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keframe/keframe.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/updater/document_controller.dart';

import '../../editor/base/builder_block.dart';
import '../../editor/main/editor_builder.dart';
import '../../theme/editor_theme_styles.dart';
import '../../updater/text_holder.dart';

/// 名词解释组件
///
/// 最 外层的single 代表这个组件
/// <simple></simple>
///
/// 持有一个单一的[BuilderBlock]
class SingleBlock extends ConsumerStatefulWidget {
  const SingleBlock({
    Key? key,
    required this.controller,
    required this.parentPath,
    required this.node,
    this.readOnly = false,
  }) : super(key: key);

  final DocumentController controller;
  final Path parentPath;
  final Node node;
  final bool readOnly;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SingleBlockState();
  }
}

class _SingleBlockState extends ConsumerState<SingleBlock> {
  late TextHolder textHolder;

  @override
  void initState() {
    textHolder = TextHolder(widget.parentPath, widget.node);
    widget.controller.dirtyUpdater.addTextHolder(widget.node.kId, textHolder);
    super.initState();
  }

  void onNodeDirty() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final ownerId = node.kId;
    final nodeTheme = ref.watch(nodeThemeProvider);
    final nodeStyle =
        nodeTheme.nodeStyleData.getNodeStyleByDepth(node.nodeCache.depth!);
    return FrameSeparateWidget(
      index: widget.parentPath.last,
      child:  Container(
          decoration: nodeStyle.borderDecoration,
          padding: nodeStyle.padding,
          child: EditorBuilder(
            ownerId: ownerId,
            focusNode: FocusNode(debugLabel: 'EditorNode $ownerId'),
            readOnly: widget.readOnly,
            autoFocus: true,
            textHolder: textHolder,
            parentPath: widget.parentPath,
            padding: EdgeInsets.zero,
          ),
        ),
    );
  }

  @override
  void dispose() {
    AppLogger.docLog.i('dirtyUpdater.removeTextHolder');
    widget.controller.dirtyUpdater.removeTextHolder(widget.node.kId, textHolder);
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:slate/slate.dart';

import '../../updater/dirty_updater.dart';
import '../../updater/document_controller.dart';
import '../../updater/text_holder.dart';
import '../_config.dart';
import '../theme/editor_icon_button.dart';
import '../theme/editor_icon_theme.dart';

class IndentButton extends StatefulWidget {
  const IndentButton({
    required this.icon,
    required this.dirtyUpdater,
    required this.isIncrease,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final DirtyUpdater dirtyUpdater;
  final bool isIncrease;

  final EditorIconTheme? iconTheme;

  @override
  _IndentButtonState createState() => _IndentButtonState();
}

class _IndentButtonState extends State<IndentButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor =
        widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor;
    return EditorIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * 1.77,
      icon: Icon(widget.icon, size: widget.iconSize, color: iconColor),
      fillColor: iconFillColor,
      onPressed: () {
        final document = widget.dirtyUpdater.document;
        final attributeMap = EditorMark.getMarks(document);
        final indent = attributeMap[AttributeRegister.indent.key];
        if (indent == null) {
          if (widget.isIncrease) {
            NodeTransforms.setNodes(document,
                {AttributeRegister.indentL1.key: AttributeRegister.indentL1});
          }
          return;
        }
        if (indent.value == 1 && !widget.isIncrease) {
          NodeTransforms.setNodes(
              document, {AttributeRegister.indentL1.key: null});
          return;
        }
        if (widget.isIncrease) {
          NodeTransforms.setNodes(document, {
            AttributeRegister.indentL1.key:
                AttributeRegister.getIndentLevel(indent.value + 1)
          });
          return;
        }
        NodeTransforms.setNodes(document, {
          AttributeRegister.indentL1.key:
              AttributeRegister.getIndentLevel(indent.value - 1)
        });
      },
    );
  }
}

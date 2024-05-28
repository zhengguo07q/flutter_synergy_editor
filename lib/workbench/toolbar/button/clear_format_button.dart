import 'package:flutter/material.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/toolbar/theme/editor_icon_theme.dart';
import 'package:thinkhub_client/workbench/updater/text_holder.dart';

import '../../updater/dirty_updater.dart';
import '../../updater/document_controller.dart';
import '../_config.dart';
import '../theme/editor_icon_button.dart';

class ClearFormatButton extends StatefulWidget {
  const ClearFormatButton({
    required this.icon,
    required this.dirtyUpdater,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final DirtyUpdater dirtyUpdater;

  final EditorIconTheme? iconTheme;

  @override
  _ClearFormatButtonState createState() => _ClearFormatButtonState();
}

class _ClearFormatButtonState extends State<ClearFormatButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor =
        widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final fillColor =
        widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor;
    return EditorIconButton(
        highlightElevation: 0,
        hoverElevation: 0,
        size: widget.iconSize * kIconButtonFactor,
        icon: Icon(widget.icon, size: widget.iconSize, color: iconColor),
        fillColor: fillColor,
        onPressed: () {
          final attributeMap = EditorMark.getMarks(widget.dirtyUpdater.document);
          NodeTransforms.unsetNodes(
              widget.dirtyUpdater.document, attributeMap.keys);
        });
  }
}

import 'package:flutter/material.dart' hide Element, Text;
import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/toolbar/util/active_util.dart';

import '../../updater/dirty_updater.dart';
import '../../updater/text_holder.dart';
import '../_config.dart';
import '../theme/editor_icon_button.dart';
import '../theme/editor_icon_theme.dart';

typedef ToggleStyleButtonBuilder = Widget Function(
  BuildContext context,
  Attribute attribute,
  IconData icon,
  Color? fillColor,
  bool? isToggled,
  VoidCallback? onPressed, [
  double iconSize,
  EditorIconTheme? iconTheme,
]);

/// 可切换的按钮
class ToggleStyleButton extends StatefulWidget {
  const ToggleStyleButton({
    required this.attribute,
    required this.icon,
    required this.dirtyUpdater,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.childBuilder = defaultToggleStyleButtonBuilder,
    this.iconTheme,
    Key? key,
  }) : super(key: key);

  final Attribute attribute;

  final IconData icon;

  final double iconSize;

  final Color? fillColor;

  final DirtyUpdater dirtyUpdater;

  final ToggleStyleButtonBuilder childBuilder;

  /// 为工具栏中的图标指定图标主题
  final EditorIconTheme? iconTheme;

  @override
  _ToggleStyleButtonState createState() => _ToggleStyleButtonState();
}

class _ToggleStyleButtonState extends State<ToggleStyleButton> {
  bool? _isToggled;

  bool get isActive => ActiveUtil.isMarkActive(
      widget.dirtyUpdater.document, widget.attribute.key,
      isCollapsed: false);

  @override
  void initState() {
    super.initState();
    _isToggled = isActive;
    widget.dirtyUpdater.addListener(_onTextUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(
      context,
      widget.attribute,
      widget.icon,
      widget.fillColor,
      _isToggled,
      _toggleAttribute,
      widget.iconSize,
      widget.iconTheme,
    );
  }

  @override
  void didUpdateWidget(covariant ToggleStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dirtyUpdater != widget.dirtyUpdater) {
      oldWidget.dirtyUpdater.removeListener(_onTextUpdate);
      widget.dirtyUpdater.addListener(_onTextUpdate);
      _isToggled = isActive;
    }
  }

  @override
  void dispose() {
    widget.dirtyUpdater.removeListener(_onTextUpdate);
    super.dispose();
  }

  void _onTextUpdate() {
    setState(() => _isToggled = isActive);
  }

  void _toggleAttribute() {
    _isToggled!
        ? NodeTransforms.unsetNodes(
            widget.dirtyUpdater.document, widget.attribute.key,
            match: ({Node? node, Path? path}) => KText.isText(node!),
            split: true)
        : NodeTransforms.setNodes(widget.dirtyUpdater.document,
            {widget.attribute.key: widget.attribute},
            match: ({Node? node, Path? path}) => KText.isText(node!),
            split: true);
  }
}

Widget defaultToggleStyleButtonBuilder(
  BuildContext context,
  Attribute attribute,
  IconData icon,
  Color? fillColor,
  bool? isToggled,
  VoidCallback? onPressed, [
  double iconSize = kDefaultIconSize,
  EditorIconTheme? iconTheme,
]) {
  final theme = Theme.of(context);
  final isEnabled = onPressed != null;
  final iconColor = isEnabled
      ? isToggled == true
          ? (iconTheme?.iconSelectedColor ??
              theme
                  .primaryIconTheme.color) //You can specify your own icon color
          : (iconTheme?.iconUnselectedColor ?? theme.iconTheme.color)
      : (iconTheme?.disabledIconColor ?? theme.disabledColor);
  final fill = isEnabled
      ? isToggled == true
          ? (iconTheme?.iconSelectedFillColor ??
              theme.toggleableActiveColor) //Selected icon fill color
          : (iconTheme?.iconUnselectedFillColor ??
              theme.canvasColor) //Unselected icon fill color :
      : (iconTheme?.disabledIconFillColor ??
          (fillColor ?? theme.canvasColor)); //Disabled icon fill color
  return EditorIconButton(
    highlightElevation: 0,
    hoverElevation: 0,
    size: iconSize * kIconButtonFactor,
    icon: Icon(icon, size: iconSize, color: iconColor),
    fillColor: fill,
    onPressed: onPressed,
  );
}

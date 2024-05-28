import 'package:flutter/material.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/toolbar/button/toggle_style_button.dart';

import '../../editor/base/builder_block.dart';
import '../../updater/dirty_updater.dart';
import '../_config.dart';
import '../theme/editor_icon_theme.dart';

class ToggleCheckListButton extends StatefulWidget {
  const ToggleCheckListButton({
    required this.icon,
    required this.dirtyUpdater,
    required this.attribute,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.childBuilder = defaultToggleStyleButtonBuilder,
    this.iconTheme,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final Color? fillColor;

  final DirtyUpdater dirtyUpdater;

  final ToggleStyleButtonBuilder childBuilder;

  final Attribute attribute;

  final EditorIconTheme? iconTheme;

  @override
  _ToggleCheckListButtonState createState() => _ToggleCheckListButtonState();
}

class _ToggleCheckListButtonState extends State<ToggleCheckListButton> {
  bool? _isToggled;

  Map<String, Attribute> get _selectionStyle =>
      EditorMark.getMarks(widget.dirtyUpdater.document);

  void _onTextUpdate() {
    setState(() {
      _isToggled = _getIsToggled(_selectionStyle);
    });
  }

  @override
  void initState() {
    super.initState();
    _isToggled = _getIsToggled(_selectionStyle);
    widget.dirtyUpdater.addListener(_onTextUpdate);
  }

  bool _getIsToggled(Map<String, Attribute> attrs) {
    var attribute =
        widget.dirtyUpdater.toolbarButtonToggle[AttributeRegister.list.key];

    if (attribute == null) {
      attribute = attrs[AttributeRegister.list.key];
    } else {
      // checkbox tapping causes controller.selection to go to offset 0
      widget.dirtyUpdater.toolbarButtonToggle
          .remove(AttributeRegister.list.key);
    }

    if (attribute == null) {
      return false;
    }
    return attribute.value == AttributeRegister.unchecked.value ||
        attribute.value == AttributeRegister.checked.value;
  }

  @override
  void didUpdateWidget(covariant ToggleCheckListButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dirtyUpdater != widget.dirtyUpdater) {
      oldWidget.dirtyUpdater.removeListener(_onTextUpdate);
      widget.dirtyUpdater.addListener(_onTextUpdate);
      _isToggled = _getIsToggled(_selectionStyle);
    }
  }

  @override
  void dispose() {
    widget.dirtyUpdater.removeListener(_onTextUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(
      context,
      AttributeRegister.unchecked,
      widget.icon,
      widget.fillColor,
      _isToggled,
      _toggleAttribute,
      widget.iconSize,
      widget.iconTheme,
    );
  }

  void _toggleAttribute() {
    final document = widget.dirtyUpdater.document;
    _isToggled!
        ? NodeTransforms.unsetNodes(document, AttributeRegister.unchecked.key,
            match: ({Node? node, Path? path}) =>
                EditorCondition.isType(document, node!, BuilderBlock.block))
        : NodeTransforms.setNodes(document,
            {AttributeRegister.unchecked.key: AttributeRegister.unchecked},
            match: ({Node? node, Path? path}) =>
                EditorCondition.isType(document, node!, BuilderBlock.block));
  }
}

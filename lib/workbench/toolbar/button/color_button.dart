import 'package:crdt/crdt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/updater/document_controller.dart';
import 'package:thinkhub_client/workbench/toolbar/theme/editor_icon_theme.dart';
import 'package:thinkhub_client/workbench/updater/text_holder.dart';

import '../../../core/utils/color.dart';
import '../../updater/dirty_updater.dart';
import '../_config.dart';
import '../theme/editor_icon_button.dart';

class ColorButton extends StatefulWidget {
  const ColorButton({
    required this.icon,
    required this.dirtyUpdater,
    required this.background,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final bool background;
  final DirtyUpdater dirtyUpdater;
  final EditorIconTheme? iconTheme;

  @override
  _ColorButtonState createState() => _ColorButtonState();
}

class _ColorButtonState extends State<ColorButton> {
  late bool _isToggledColor;
  late bool _isToggledBackground;
  late bool _isWhite;
  late bool _isWhiteBackground;

  Map<String, Attribute> get _selectionStyle =>
      EditorMark.getMarks(widget.dirtyUpdater.document, isCollapsed: false);

  void _onTextUpdate() {
    setState(() {
      _isToggledColor = _getIsToggledColor(_selectionStyle);
      _isToggledBackground = _getIsToggledBackground(_selectionStyle);
      _isWhite =
          _isToggledColor && _selectionStyle['color']!.value == '#ffffff';
      _isWhiteBackground = _isToggledBackground &&
          _selectionStyle['background']!.value == '#ffffff';
    });
  }

  @override
  void initState() {
    super.initState();
    _isToggledColor = _getIsToggledColor(_selectionStyle);
    _isToggledBackground = _getIsToggledBackground(_selectionStyle);
    _isWhite = _isToggledColor && _selectionStyle['color']!.value == '#ffffff';
    _isWhiteBackground = _isToggledBackground &&
        _selectionStyle['background']!.value == '#ffffff';
    widget.dirtyUpdater.addListener(_onTextUpdate);
  }

  bool _getIsToggledColor(Map<String, Attribute> attrs) {
    return attrs.containsKey(AttributeRegister.color.key);
  }

  bool _getIsToggledBackground(Map<String, Attribute> attrs) {
    return attrs.containsKey(AttributeRegister.background.key);
  }

  @override
  void didUpdateWidget(covariant ColorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dirtyUpdater != widget.dirtyUpdater) {
      oldWidget.dirtyUpdater.removeListener(_onTextUpdate);
      widget.dirtyUpdater.addListener(_onTextUpdate);
      _isToggledColor = _getIsToggledColor(_selectionStyle);
      _isToggledBackground = _getIsToggledBackground(_selectionStyle);
      _isWhite =
          _isToggledColor && _selectionStyle['color']!.value == '#ffffff';
      _isWhiteBackground = _isToggledBackground &&
          _selectionStyle['background']!.value == '#ffffff';
    }
  }

  @override
  void dispose() {
    widget.dirtyUpdater.removeListener(_onTextUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _isToggledColor && !widget.background && !_isWhite
        ? stringToColor(_selectionStyle['color']!.value)
        : (widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color);

    final iconColorBackground =
        _isToggledBackground && widget.background && !_isWhiteBackground
            ? stringToColor(_selectionStyle['background']!.value)
            : (widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color);

    final fillColor = _isToggledColor && !widget.background && _isWhite
        ? stringToColor('#ffffff')
        : (widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor);
    final fillColorBackground =
        _isToggledBackground && widget.background && _isWhiteBackground
            ? stringToColor('#ffffff')
            : (widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor);

    return EditorIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * kIconButtonFactor,
      icon: Icon(widget.icon,
          size: widget.iconSize,
          color: widget.background ? iconColorBackground : iconColor),
      fillColor: widget.background ? fillColorBackground : fillColor,
      onPressed: _showColorPicker,
    );
  }

  void _changeColor(BuildContext context, Color color) {
    var hex = color.value.toRadixString(16);
    if (hex.startsWith('ff')) {
      hex = hex.substring(2);
    }
    hex = '#$hex';
    if(widget.background){
      EditorMark.addMark(widget.dirtyUpdater.document, AttributeRegister.background.key, BackgroundAttribute(hex));
    }else{
      EditorMark.addMark(widget.dirtyUpdater.document, AttributeRegister.color.key, ColorAttribute(hex));
    }
    Navigator.of(context).pop();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        backgroundColor: Theme.of(context).canvasColor,
        content: SingleChildScrollView(
          child: MaterialPicker(
            pickerColor: const Color(0x00000000),
            onColorChanged: (color) => _changeColor(context, color),
          ),
        ),
      ),
    );
  }
}

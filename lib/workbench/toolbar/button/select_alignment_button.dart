import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slate/slate.dart';

import '../../updater/dirty_updater.dart';
import '../../updater/text_holder.dart';
import '../_config.dart';
import '../theme/editor_icon_theme.dart';

class SelectAlignmentButton extends StatefulWidget {
  const SelectAlignmentButton({
    required this.dirtyUpdater,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    this.showLeftAlignment,
    this.showCenterAlignment,
    this.showRightAlignment,
    this.showJustifyAlignment,
    Key? key,
  }) : super(key: key);

  final DirtyUpdater dirtyUpdater;
  final double iconSize;

  final EditorIconTheme? iconTheme;
  final bool? showLeftAlignment;
  final bool? showCenterAlignment;
  final bool? showRightAlignment;
  final bool? showJustifyAlignment;

  @override
  _SelectAlignmentButtonState createState() => _SelectAlignmentButtonState();
}

class _SelectAlignmentButtonState extends State<SelectAlignmentButton> {
  Attribute? _value;

  Map<String, Attribute> get _selectionStyle =>
      EditorMark.getMarks(widget.dirtyUpdater.document);

  @override
  void initState() {
    super.initState();
    setState(() {
      _value = _selectionStyle[AttributeRegister.align.key] ??
          AttributeRegister.leftAlignment;
    });
    widget.dirtyUpdater.addListener(_onTextUpdate);
  }

  @override
  Widget build(BuildContext context) {
    final _valueToText = <Attribute, String>{
      if (widget.showLeftAlignment!)
        AttributeRegister.leftAlignment: AttributeRegister.leftAlignment.value!,
      if (widget.showCenterAlignment!)
        AttributeRegister.centerAlignment:
            AttributeRegister.centerAlignment.value!,
      if (widget.showRightAlignment!)
        AttributeRegister.rightAlignment:
            AttributeRegister.rightAlignment.value!,
      if (widget.showJustifyAlignment!)
        AttributeRegister.justifyAlignment:
            AttributeRegister.justifyAlignment.value!,
    };

    final _valueAttribute = <Attribute>[
      if (widget.showLeftAlignment!) AttributeRegister.leftAlignment,
      if (widget.showCenterAlignment!) AttributeRegister.centerAlignment,
      if (widget.showRightAlignment!) AttributeRegister.rightAlignment,
      if (widget.showJustifyAlignment!) AttributeRegister.justifyAlignment
    ];
    final _valueString = <String>[
      if (widget.showLeftAlignment!) AttributeRegister.leftAlignment.value!,
      if (widget.showCenterAlignment!) AttributeRegister.centerAlignment.value!,
      if (widget.showRightAlignment!) AttributeRegister.rightAlignment.value!,
      if (widget.showJustifyAlignment!)
        AttributeRegister.justifyAlignment.value!,
    ];

    final theme = Theme.of(context);

    final buttonCount = ((widget.showLeftAlignment!) ? 1 : 0) +
        ((widget.showCenterAlignment!) ? 1 : 0) +
        ((widget.showRightAlignment!) ? 1 : 0) +
        ((widget.showJustifyAlignment!) ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(buttonCount, (index) {
        return Padding(
          // ignore: prefer_const_constructors
          padding: EdgeInsets.symmetric(horizontal: !kIsWeb ? 1.0 : 5.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: widget.iconSize * kIconButtonFactor,
              height: widget.iconSize * kIconButtonFactor,
            ),
            child: RawMaterialButton(
              hoverElevation: 0,
              highlightElevation: 0,
              elevation: 0,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
              fillColor: _valueToText[_value] == _valueString[index]
                  ? (widget.iconTheme?.iconSelectedFillColor ??
                      theme.toggleableActiveColor)
                  : (widget.iconTheme?.iconUnselectedFillColor ??
                      theme.canvasColor),
              onPressed: () {
                _valueAttribute[index] == AttributeRegister.leftAlignment
                    ? NodeTransforms.unsetNodes(
                        widget.dirtyUpdater.document,
                        AttributeRegister.align.key,
                      )
                    : NodeTransforms.setNodes(
                        widget.dirtyUpdater.document,
                        {AttributeRegister.align.key: _valueAttribute[index]},
                      );
              },
              child: Icon(
                _valueString[index] == AttributeRegister.leftAlignment.value
                    ? Icons.format_align_left
                    : _valueString[index] ==
                            AttributeRegister.centerAlignment.value
                        ? Icons.format_align_center
                        : _valueString[index] ==
                                AttributeRegister.rightAlignment.value
                            ? Icons.format_align_right
                            : Icons.format_align_justify,
                size: widget.iconSize,
                color: _valueToText[_value] == _valueString[index]
                    ? (widget.iconTheme?.iconSelectedColor ??
                        theme.primaryIconTheme.color)
                    : (widget.iconTheme?.iconUnselectedColor ??
                        theme.iconTheme.color),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _onTextUpdate() {
    setState(() {
      _value = _selectionStyle[AttributeRegister.align.key] ??
          AttributeRegister.leftAlignment;
    });
  }

  @override
  void didUpdateWidget(covariant SelectAlignmentButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dirtyUpdater != widget.dirtyUpdater) {
      oldWidget.dirtyUpdater.removeListener(_onTextUpdate);
      widget.dirtyUpdater.addListener(_onTextUpdate);
      _value = _selectionStyle[AttributeRegister.align.key] ??
          AttributeRegister.leftAlignment;
    }
  }

  @override
  void dispose() {
    widget.dirtyUpdater.removeListener(_onTextUpdate);
    super.dispose();
  }
}

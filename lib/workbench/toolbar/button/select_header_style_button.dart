import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:slate/slate.dart';

import '../../updater/dirty_updater.dart';
import '../../updater/text_holder.dart';
import '../_config.dart';
import '../theme/editor_icon_theme.dart';

class SelectHeaderStyleButton extends StatefulWidget {
  const SelectHeaderStyleButton({
    required this.dirtyUpdater,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    Key? key,
  }) : super(key: key);

  final DirtyUpdater dirtyUpdater;
  final double iconSize;

  final EditorIconTheme? iconTheme;

  @override
  _SelectHeaderStyleButtonState createState() =>
      _SelectHeaderStyleButtonState();
}

class _SelectHeaderStyleButtonState extends State<SelectHeaderStyleButton> {
  Attribute? _value;

  Map<String, Attribute> get _selectionStyle =>
      EditorMark.getMarks(widget.dirtyUpdater.document);

  @override
  void initState() {
    super.initState();
    setState(() {
      _value = _getHeaderValue();
    });
    widget.dirtyUpdater.addListener(_didChangeEditingValue);
  }

  @override
  Widget build(BuildContext context) {
    final _valueToText = <Attribute, String>{
      AttributeRegister.header: 'N',
      AttributeRegister.h1: 'H1',
      AttributeRegister.h2: 'H2',
      AttributeRegister.h3: 'H3',
    };

    final _valueAttribute = <Attribute>[
      AttributeRegister.header,
      AttributeRegister.h1,
      AttributeRegister.h2,
      AttributeRegister.h3
    ];
    final _valueString = <String>['N', 'H1', 'H2', 'H3'];

    final theme = Theme.of(context);
    final style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: widget.iconSize * 0.7,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
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
                // 得到行节点
                final document = widget.dirtyUpdater.document;
                if (_valueAttribute[index] == AttributeRegister.header) {
                  NodeTransforms.unsetNodes(
                    document,
                    AttributeRegister.header.key,
                    match: ({Node? node, Path? path}) =>
                        node!.type == ElementType.tagLine,
                  );
                } else {
                  final attributeMap = {
                    AttributeRegister.header.key: _valueAttribute[index]
                  };
                  NodeTransforms.setNodes(
                    document,
                    attributeMap,
                    match: ({Node? node, Path? path}) =>
                        node!.type == ElementType.tagLine,
                  );
                }
              },
              child: Text(
                _valueString[index],
                style: style.copyWith(
                  color: _valueToText[_value] == _valueString[index]
                      ? (widget.iconTheme?.iconSelectedColor ??
                          theme.primaryIconTheme.color)
                      : (widget.iconTheme?.iconUnselectedColor ??
                          theme.iconTheme.color),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _didChangeEditingValue() {
    setState(() {
      _value = _getHeaderValue();
    });
  }

  Attribute<dynamic> _getHeaderValue() {
    final attr =
        widget.dirtyUpdater.toolbarButtonToggle[AttributeRegister.header.key];
    if (attr != null) {
      widget.dirtyUpdater.toolbarButtonToggle
          .remove(AttributeRegister.header.key);
      return attr;
    }
    return _selectionStyle[AttributeRegister.header.key] ??
        AttributeRegister.header;
  }

  @override
  void didUpdateWidget(covariant SelectHeaderStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dirtyUpdater != widget.dirtyUpdater) {
      oldWidget.dirtyUpdater.removeListener(_didChangeEditingValue);
      widget.dirtyUpdater.addListener(_didChangeEditingValue);
      _value = _getHeaderValue();
    }
  }

  @override
  void dispose() {
    widget.dirtyUpdater.removeListener(_didChangeEditingValue);
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/updater/text_holder.dart';
import 'package:tuple/tuple.dart';

import '../../updater/dirty_updater.dart';
import '../../updater/document_controller.dart';
import '../../editor/base/link/link_config.dart';
import '../_config.dart';
import '../theme/editor_icon_button.dart';
import '../theme/editor_icon_theme.dart';
import '../theme/editor_dialog_theme.dart';

class LinkStyleButton extends StatefulWidget {
  const LinkStyleButton({
    required this.dirtyUpdater,
    this.iconSize = kDefaultIconSize,
    this.icon,
    this.iconTheme,
    this.dialogTheme,
    Key? key,
  }) : super(key: key);

  final DirtyUpdater dirtyUpdater;
  final IconData? icon;
  final double iconSize;
  final EditorIconTheme? iconTheme;
  final EditorDialogTheme? dialogTheme;

  @override
  _LinkStyleButtonState createState() => _LinkStyleButtonState();
}

class _LinkStyleButtonState extends State<LinkStyleButton> {
  void _didChangeSelection() {
    setState(() {});
  }

  Map<String, Attribute> get _selectionStyle =>
      EditorMark.getMarks(widget.dirtyUpdater.document);

  @override
  void initState() {
    super.initState();
    widget.dirtyUpdater.addListener(_didChangeSelection);
  }

  @override
  void didUpdateWidget(covariant LinkStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dirtyUpdater != widget.dirtyUpdater) {
      oldWidget.dirtyUpdater.removeListener(_didChangeSelection);
      widget.dirtyUpdater.addListener(_didChangeSelection);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.dirtyUpdater.removeListener(_didChangeSelection);
  }

  final GlobalKey _toolTipKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToggled = _getLinkAttributeValue() != null;
    final pressedHandler = () => _openLinkDialog(context);
    return GestureDetector(
      onTap: () async {
        final dynamic tooltip = _toolTipKey.currentState;
        tooltip.ensureTooltipVisible();
        Future.delayed(
          const Duration(
            seconds: 3,
          ),
          tooltip.deactivate,
        );
      },
      child: Tooltip(
        key: _toolTipKey,
        message: 'Please first select some part to transform into a link.',
        child: EditorIconButton(
          highlightElevation: 0,
          hoverElevation: 0,
          size: widget.iconSize * kIconButtonFactor,
          icon: Icon(
            widget.icon ?? Icons.link,
            size: widget.iconSize,
            color: isToggled
                ? (widget.iconTheme?.iconUnselectedColor ??
                    theme.iconTheme.color)
                : (widget.iconTheme?.disabledIconColor ?? theme.disabledColor),
          ),
          fillColor:
              widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor,
          onPressed: pressedHandler,
        ),
      ),
    );
  }

  void _openLinkDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder: (ctx) {
        final link = _getLinkAttributeValue();
        // final index = widget.controller.selection.start;
        //
        // var part;
        // if (link != null) {
        //   // part should be the link's corresponding part, not selection
        //   final leaf =
        //       widget.controller.document.querySegmentLeafNode(index).item2;
        //   if (leaf != null) {
        //     part = leaf.toPlainText();
        //   }
        // }
        //
        // final len = widget.controller.selection.end - index;
        // part ??=
        //     len == 0 ? '' : widget.controller.document.getPlainText(index, len);
        const text = "";
        return _LinkDialog(
            dialogTheme: widget.dialogTheme, link: link, text: text);
      },
    ).then(
      (value) {
        if (value != null) _linkSubmitted(value);
      },
    );
  }

  String? _getLinkAttributeValue() {
    return _selectionStyle[AttributeRegister.link.key]
        ?.value;
  }

  void _linkSubmitted(dynamic value) {
    // part.isNotEmpty && link.isNotEmpty
    // final String part = (value as Tuple2).item1;
    // final String link = value.item2.trim();
    //
    // var index = widget.controller.selection.start;
    // var length = widget.controller.selection.end - index;
    // if (_getLinkAttributeValue() != null) {
    //   // part should be the link's corresponding part, not selection
    //   final leaf = widget.controller.document.querySegmentLeafNode(index).item2;
    //   if (leaf != null) {
    //     final range = getLinkRange(leaf);
    //     index = range.start;
    //     length = range.end - range.start;
    //   }
    // }
    // widget.controller.replaceText(index, length, part, null);
    // widget.controller.formatText(index, part.length, LinkAttribute(link));
  }
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({this.dialogTheme, this.link, this.text, Key? key})
      : super(key: key);

  final EditorDialogTheme? dialogTheme;
  final String? link;
  final String? text;

  @override
  _LinkDialogState createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  late String _link;
  late String _text;
  late TextEditingController _linkController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _link = widget.link ?? '';
    _text = widget.text ?? '';
    _linkController = TextEditingController(text: _link);
    _textController = TextEditingController(text: _text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.multiline,
            style: widget.dialogTheme?.inputTextStyle,
            decoration: InputDecoration(
                labelText: 'Text',
                labelStyle: widget.dialogTheme?.labelTextStyle,
                floatingLabelStyle: widget.dialogTheme?.labelTextStyle),
            autofocus: true,
            onChanged: _textChanged,
            controller: _textController,
          ),
          const SizedBox(height: 16),
          TextField(
            keyboardType: TextInputType.multiline,
            style: widget.dialogTheme?.inputTextStyle,
            decoration: InputDecoration(
                labelText: 'Link',
                labelStyle: widget.dialogTheme?.labelTextStyle,
                floatingLabelStyle: widget.dialogTheme?.labelTextStyle),
            autofocus: true,
            onChanged: _linkChanged,
            controller: _linkController,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _canPress() ? _applyLink : null,
          child: Text(
            'Ok',
            style: widget.dialogTheme?.labelTextStyle,
          ),
        ),
      ],
    );
  }

  bool _canPress() {
    if (_text.isEmpty || _link.isEmpty) {
      return false;
    }

    if (!linkRegExp.hasMatch(_link)) {
      return false;
    }

    return true;
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  void _textChanged(String value) {
    setState(() {
      _text = value;
    });
  }

  void _applyLink() {
    Navigator.pop(context, Tuple2(_text.trim(), _link.trim()));
  }
}

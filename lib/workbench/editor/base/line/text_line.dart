import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slate/slate.dart' hide KElement;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/color.dart';
import '../../../updater/text_holder.dart';
import '../../../util/platform.dart';
import '../../../updater/document_controller.dart';
import '../../core/keyboard/keyboard_pressed_keys.dart';
import '../../core/proxy/embed_proxy.dart';
import '../../core/proxy/rich_text_proxy.dart';
import '../../embed/default_embed_builder.dart';
import '../../embed/embde.dart';
import '../link/link_config.dart';
import '../link/link_show_menu.dart';
import '../style/style_default.dart';

class TextLine extends StatefulWidget {
  const TextLine({
    required this.textHolder,
    required this.line,
    required this.styles,
    required this.readOnly,
    this.textDirection,
    Key? key,
  }) : super(key: key);

  final TextHolder textHolder;
  final Node line;
  final TextDirection? textDirection;
  final StyleTextData styles;
  final bool readOnly;

  @override
  State<TextLine> createState() => _TextLineState();
}

class _TextLineState extends State<TextLine> {
  bool _metaOrControlPressed = false;

  UniqueKey _richTextKey = UniqueKey();

  final _linkRecognizers = <Node, GestureRecognizer>{};

  KeyboardPressedKeysNotifier? _pressedKeys;

  void _pressedKeysChanged() {
    final newValue = _pressedKeys!.metaPressed || _pressedKeys!.controlPressed;
    if (_metaOrControlPressed != newValue) {
      setState(() {
        _metaOrControlPressed = newValue;
        _richTextKey = UniqueKey();
      });
    }
  }

  bool get canLaunchLinks {
    if (widget.readOnly) return true;
    if (isDesktop()) {
      return _metaOrControlPressed;
    }
    return true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pressedKeys == null) {
      _pressedKeys = KeyboardPressedKeysNotifier.of(context);
      _pressedKeys!.addListener(_pressedKeysChanged);
    } else {
      _pressedKeys!.removeListener(_pressedKeysChanged);
      _pressedKeys = KeyboardPressedKeysNotifier.of(context);
      _pressedKeys!.addListener(_pressedKeysChanged);
    }
  }

  @override
  void didUpdateWidget(covariant TextLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.readOnly != widget.readOnly) {
      _richTextKey = UniqueKey();
      _linkRecognizers
        ..forEach((key, value) {
          value.dispose();
        })
        ..clear();
    }
  }

  @override
  void dispose() {
    _pressedKeys?.removeListener(_pressedKeysChanged);
    _linkRecognizers
      ..forEach((key, value) => value.dispose())
      ..clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    if (Embed.isEmbed(widget.line)) {
      final embed = widget.line.children.first;
      return EmbedProxy(embedBuilder(
          context, widget.textHolder, embed, widget.readOnly));
    }
    final textSpan = _getTextSpanForWholeLine(context);
    final strutStyle = StrutStyle.fromTextStyle(textSpan.style!);
    final textAlign = _getTextAlign();
    final child = RichText(
      key: _richTextKey,
      text: textSpan,
      textAlign: textAlign,
      textDirection: widget.textDirection,
      strutStyle: strutStyle,
      textScaleFactor: MediaQuery.textScaleFactorOf(context),
    );
    return RichTextProxy(
        textStyle: textSpan.style!,
        textAlign: textAlign,
        textDirection: widget.textDirection!,
        strutStyle: strutStyle,
        locale: Localizations.localeOf(context),
        child: child);
  }

  /// 得到整行的文本块
  InlineSpan _getTextSpanForWholeLine(BuildContext context) {
    final lineStyle = _getLineStyle(widget.styles);
    if (!Embed.isEmbed(widget.line)) {
      return _buildTextSpan(widget.styles, widget.line.children, lineStyle);
    }

    // The line could contain more than one Embed & more than one Text
    final textSpanChildren = <InlineSpan>[];
    var textNodes = <Node>[];
    for (final child in widget.line.children) {
      if (child is Embed) {
        if (textNodes.isNotEmpty) {
          textSpanChildren
              .add(_buildTextSpan(widget.styles, textNodes, lineStyle));
          textNodes = [];
        }
        // Here it should be image
        final embed = WidgetSpan(
            child: EmbedProxy(embedBuilder(
                context, widget.textHolder, child, widget.readOnly)));
        textSpanChildren.add(embed);
        continue;
      }

      // here child is Text node and its value is cloned
      textNodes.add(child.clone());
    }

    if (textNodes.isNotEmpty) {
      textSpanChildren.add(_buildTextSpan(widget.styles, textNodes, lineStyle));
    }

    return TextSpan(style: lineStyle, children: textSpanChildren);
  }

  TextAlign _getTextAlign() {
    final alignment = widget.line.attributes[AttributeRegister.align.key];
    if (alignment == AttributeRegister.leftAlignment) {
      return TextAlign.start;
    } else if (alignment == AttributeRegister.centerAlignment) {
      return TextAlign.center;
    } else if (alignment == AttributeRegister.rightAlignment) {
      return TextAlign.end;
    } else if (alignment == AttributeRegister.justifyAlignment) {
      return TextAlign.justify;
    }
    return TextAlign.start;
  }

  /// 构建行内所有子节点文本样式
  TextSpan _buildTextSpan(StyleTextData defaultStyles, List<Node> nodes,
      TextStyle lineStyle) {
    if (nodes.isEmpty && kIsWeb) {
      nodes = <Node>[Node(text: '\u{200B}')];
    }
    final children = nodes
        .map((node) =>
        _getTextSpanFromNode(defaultStyles, node, widget.line.attributes))
        .toList(growable: false);

    return TextSpan(children: children, style: lineStyle);
  }

  /// 行自身的样式， 比如整行加粗， 独占， 代码块特殊样式等
  TextStyle _getLineStyle(StyleTextData defaultStyles) {
    var textStyle = const TextStyle();

    // 整行是一个占位符
    if (widget.line.attributes.containsKey(AttributeRegister.placeholder.key)) {
      return defaultStyles.placeHolder!.style;
    }

    // 整行是一个H1-H3加粗段落
    final header = widget.line.attributes[AttributeRegister.header.key];
    final m = <Attribute, TextStyle>{
      AttributeRegister.h1: defaultStyles.h1!.style,
      AttributeRegister.h2: defaultStyles.h2!.style,
      AttributeRegister.h3: defaultStyles.h3!.style,
    };

    textStyle = textStyle.merge(m[header] ?? defaultStyles.paragraph!.style);

    // 行样式中的独占块格式
    Attribute? block;
    AttributeUtil.getBlocksExceptHeader(widget.line.attributes).forEach((key, value) {
      if (AttributeRegister.exclusiveBlockKeys.contains(key)) {
        block = value;
      }
    });

    TextStyle? toMerge;
    if (block == AttributeRegister.blockQuote) {
      toMerge = defaultStyles.quote!.style;
    } else if (block == AttributeRegister.codeBlock) {
      toMerge = defaultStyles.code!.style;
    } else if (block == AttributeRegister.list) {
      toMerge = defaultStyles.lists!.style;
    }

    textStyle = textStyle.merge(toMerge);
    return textStyle;
  }


  /// 构建行内特定节点样式
  TextSpan _getTextSpanFromNode(
      StyleTextData defaultStyles, Node node, Map<String, Attribute> lineStyle) {
    final textNode = node;
    final attributes = textNode.attributes;
    final isLink = attributes.containsKey(AttributeRegister.link.key) &&
        attributes[AttributeRegister.link.key] != null;

    return TextSpan(
      text: textNode.text,
      style: _getInlineTextStyle(
          textNode, defaultStyles, node.attributes, lineStyle, isLink),
      recognizer: isLink && canLaunchLinks ? _getRecognizer(node) : null,
      mouseCursor: isLink && canLaunchLinks ? SystemMouseCursors.click : null,
    );
  }

  /// 得到行内的最小单位子节点内联样式
  TextStyle _getInlineTextStyle(Node textNode, StyleTextData defaultStyles,
      Map<String, Attribute> nodeStyle, Map<String, Attribute> lineStyle, bool isLink) {
    var res = const TextStyle(); // This is inline part style
    final color = textNode.attributes[AttributeRegister.color.key];

    <String, TextStyle?>{
      AttributeRegister.bold.key: defaultStyles.bold,
      AttributeRegister.italic.key: defaultStyles.italic,
      AttributeRegister.small.key: defaultStyles.small,
      AttributeRegister.link.key: defaultStyles.link,
      AttributeRegister.underline.key: defaultStyles.underline,
      AttributeRegister.strikeThrough.key: defaultStyles.strikeThrough,
    }.forEach((k, s) {
      if (nodeStyle.values.any((v) => v.key == k)) {
        if (k == AttributeRegister.underline.key || k == AttributeRegister.strikeThrough.key) {
          var textColor = defaultStyles.color;
          if (color?.value is String) {
            textColor = stringToColor(color?.value);
          }
          res = _merge(res.copyWith(decorationColor: textColor),
              s!.copyWith(decorationColor: textColor));
        } else if (k == AttributeRegister.link.key && !isLink) {
          // null value for link should be ignored
          // i.e. nodeStyle.attributes[Attribute.link.key]!.value == null
        } else {
          res = _merge(res, s!);
        }
      }
    });

    if (nodeStyle.containsKey(AttributeRegister.inlineCode.key)) {
      res = _merge(res, defaultStyles.inlineCode!.styleFor(lineStyle));
    }

    final font = textNode.attributes[AttributeRegister.font.key];
    if (font != null && font.value != null) {
      res = res.merge(TextStyle(fontFamily: font.value));
    }

    final size = textNode.attributes[AttributeRegister.size.key];
    if (size != null) {
      switch (size.value) {
        case 'small':
          res = res.merge(defaultStyles.sizeSmall);
          break;
        case 'large':
          res = res.merge(defaultStyles.sizeLarge);
          break;
        case 'huge':
          res = res.merge(defaultStyles.sizeHuge);
          break;
        default:
          double? fontSize;
          if (size.value is double) {
            fontSize = size.value;
          } else if (size.value is int) {
            fontSize = size.value.toDouble();
          } else if (size.value is String) {
            fontSize = double.tryParse(size.value);
          }
          if (fontSize != null) {
            res = res.merge(TextStyle(fontSize: fontSize));
          } else {
            throw 'Invalid size ${size.value}';
          }
      }
    }

    if (color != null && color.value != null) {
      var textColor = defaultStyles.color;
      if (color.value is String) {
        textColor = stringToColor(color.value);
      }
      if (textColor != null) {
        res = res.merge(TextStyle(color: textColor));
      }
    }

    final background = textNode.attributes[AttributeRegister.background.key];
    if (background != null && background.value != null) {
      final backgroundColor = stringToColor(background.value);
      res = res.merge(TextStyle(backgroundColor: backgroundColor));
    }

    return res;
  }

  GestureRecognizer _getRecognizer(Node segment) {
    if (_linkRecognizers.containsKey(segment)) {
      return _linkRecognizers[segment]!;
    }

    if (isDesktop() || widget.readOnly) {
      _linkRecognizers[segment] = TapGestureRecognizer()
        ..onTap = () => _tapNodeLink(segment);
    } else {
      _linkRecognizers[segment] = LongPressGestureRecognizer()
        ..onLongPress = () => _longPressLink(segment);
    }
    return _linkRecognizers[segment]!;
  }

  Future<void> _launchUrl(String url) async {
    await launch(url);
  }

  void _tapNodeLink(Node node) {
    final link = node.attributes[AttributeRegister.link.key]!;
    _tapLink(link.value);
  }

  void _tapLink(String? link) {
    if (link == null) {
      return;
    }

    link = link.trim();
    if (!linkPrefixes
        .any((linkPrefix) => link!.toLowerCase().startsWith(linkPrefix))) {
      link = 'https://$link';
    }
    _launchUrl(link);
  }

  Future<void> _longPressLink(Node node) async {
    final link = node.attributes[AttributeRegister.link.key]!.value;
    final action = await linkActionPicker(context, node);
    switch (action) {
      case LinkMenuAction.launch:
        _tapLink(link);
        break;
      case LinkMenuAction.copy:
      // ignore: unawaited_futures
        Clipboard.setData(ClipboardData(text: link));
        break;
      case LinkMenuAction.remove:
        final range = getLinkRange(node);
        //TODO
        // widget.controller
        //     .formatText(range.start, range.end - range.start, AttributeRegister.link);
        break;
      case LinkMenuAction.none:
        break;
    }
  }

  TextStyle _merge(TextStyle a, TextStyle b) {
    final decorations = <TextDecoration?>[];
    if (a.decoration != null) {
      decorations.add(a.decoration);
    }
    if (b.decoration != null) {
      decorations.add(b.decoration);
    }
    return a.merge(b).apply(
        decoration: TextDecoration.combine(
            List.castFrom<dynamic, TextDecoration>(decorations)));
  }
}


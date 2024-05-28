import 'package:flutter/material.dart';
import 'package:thinkhub_client/workbench/editor/base/style/style_default.dart';


class AttributeStyles extends InheritedWidget {
  const AttributeStyles({
    required this.data,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  final StyleTextData data;

  @override
  bool updateShouldNotify(AttributeStyles oldWidget) {
    return data != oldWidget.data;
  }

  static StyleTextData? getStyles(BuildContext context, bool nullOk) {
    final widget = context.dependOnInheritedWidgetOfExactType<AttributeStyles>();
    if (widget == null && nullOk) {
      return null;
    }
    assert(widget != null);
    return widget!.data;
  }

  static StyleTextData? of(BuildContext context) {
    AttributeStyles? attributeStyles = context.dependOnInheritedWidgetOfExactType<AttributeStyles>();
    return attributeStyles?.data;
  }
}

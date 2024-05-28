import 'package:flutter/painting.dart';
import 'package:slate/slate.dart';
import 'package:tuple/tuple.dart';

import '../point/point_checkbox.dart';

class DefaultTextBlockStyle {
  DefaultTextBlockStyle(
    this.style,
    this.verticalSpacing,
    this.lineSpacing,
    this.decoration,
  );

  final TextStyle style;
  final Tuple2<double, double> verticalSpacing;
  final Tuple2<double, double> lineSpacing;
  final BoxDecoration? decoration;
}

class InlineCodeStyle {
  InlineCodeStyle({
    required this.style,
    this.header1,
    this.header2,
    this.header3,
    this.backgroundColor,
    this.radius,
  });

  final TextStyle style;
  final TextStyle? header1;
  final TextStyle? header2;
  final TextStyle? header3;
  final Color? backgroundColor;
  final Radius? radius;

  TextStyle styleFor(Map<String, Attribute> lineStyle) {
    if (lineStyle.containsKey(AttributeRegister.h1.key)) {
      return header1 ?? style;
    }
    if (lineStyle.containsKey(AttributeRegister.h2.key)) {
      return header2 ?? style;
    }
    if (lineStyle.containsKey(AttributeRegister.h3.key)) {
      return header3 ?? style;
    }
    return style;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! InlineCodeStyle) {
      return false;
    }
    return other.style == style &&
        other.header1 == header1 &&
        other.header2 == header2 &&
        other.header3 == header3 &&
        other.backgroundColor == backgroundColor &&
        other.radius == radius;
  }

  @override
  int get hashCode =>
      Object.hash(style, header1, header2, header3, backgroundColor, radius);
}

class DefaultListBlockStyle extends DefaultTextBlockStyle {
  DefaultListBlockStyle(
    TextStyle style,
    Tuple2<double, double> verticalSpacing,
    Tuple2<double, double> lineSpacing,
    BoxDecoration? decoration,
    this.checkboxUIBuilder,
  ) : super(style, verticalSpacing, lineSpacing, decoration);

  final CheckboxBuilder? checkboxUIBuilder;
}

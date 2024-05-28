import 'package:flutter/cupertino.dart';
import 'text_boundary.dart';

/// 组合边框， 头和尾的边框范围不同
class MixedBoundary extends TextBoundary {
  MixedBoundary(this.leadingTextBoundary, this.trailingTextBoundary);

  final TextBoundary leadingTextBoundary;
  final TextBoundary trailingTextBoundary;

  @override
  TextEditingValue get textEditingValue {
    assert(leadingTextBoundary.textEditingValue ==
        trailingTextBoundary.textEditingValue);
    return leadingTextBoundary.textEditingValue;
  }

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) =>
      leadingTextBoundary.getLeadingTextBoundaryAt(position);

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) =>
      trailingTextBoundary.getTrailingTextBoundaryAt(position);
}
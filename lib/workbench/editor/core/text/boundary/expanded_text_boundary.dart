import 'package:flutter/cupertino.dart';
import 'text_boundary.dart';

/// 使用[outerTextBoundary]扩展[innerTextBoundary]。
class ExpandedTextBoundary extends TextBoundary {
  ExpandedTextBoundary(this.innerTextBoundary, this.outerTextBoundary);

  final TextBoundary innerTextBoundary;
  final TextBoundary outerTextBoundary;

  @override
  TextEditingValue get textEditingValue {
    assert(innerTextBoundary.textEditingValue ==
        outerTextBoundary.textEditingValue);
    return innerTextBoundary.textEditingValue;
  }

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    return outerTextBoundary.getLeadingTextBoundaryAt(
      innerTextBoundary.getLeadingTextBoundaryAt(position),
    );
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return outerTextBoundary.getTrailingTextBoundaryAt(
      innerTextBoundary.getTrailingTextBoundaryAt(position),
    );
  }
}
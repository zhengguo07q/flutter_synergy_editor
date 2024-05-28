import 'package:flutter/services.dart';
import 'text_boundary.dart';

/// 单词边界
///
/// [UAX #29](https://unicode.org/reports/tr29/)
class WordBoundary extends TextBoundary {
  const WordBoundary(this.textLayout, this.textEditingValue);

  final TextLayoutMetrics textLayout;

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textLayout.getWordBoundary(position).start,
      // Word boundary seems to always report downstream on many platforms.
      affinity:
      TextAffinity.downstream, // ignore: avoid_redundant_argument_values
    );
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textLayout.getWordBoundary(position).end,
      // Word boundary seems to always report downstream on many platforms.
      affinity:
      TextAffinity.downstream, // ignore: avoid_redundant_argument_values
    );
  }
}
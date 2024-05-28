import 'package:flutter/widgets.dart';
import 'dart:ui' as ui hide TextStyle;

class ScribblePlaceholder extends WidgetSpan {
  const ScribblePlaceholder({
    required Widget child,
    ui.PlaceholderAlignment alignment = ui.PlaceholderAlignment.bottom,
    TextBaseline? baseline,
    TextStyle? style,
    required this.size,
  })  : assert(baseline != null ||
            !(identical(alignment, ui.PlaceholderAlignment.aboveBaseline) ||
                identical(alignment, ui.PlaceholderAlignment.belowBaseline) ||
                identical(alignment, ui.PlaceholderAlignment.baseline))),
        super(
          alignment: alignment,
          baseline: baseline,
          style: style,
          child: child,
        );

  final Size size;

  @override
  void build(ui.ParagraphBuilder builder,
      {double textScaleFactor = 1.0, List<PlaceholderDimensions>? dimensions}) {
    assert(debugAssertIsValid());
    final bool hasStyle = style != null;
    if (hasStyle) {
      builder.pushStyle(style!.getTextStyle(textScaleFactor: textScaleFactor));
    }
    builder.addPlaceholder(
      size.width,
      size.height,
      alignment,
      scale: textScaleFactor,
    );
    if (hasStyle) {
      builder.pop();
    }
  }
}

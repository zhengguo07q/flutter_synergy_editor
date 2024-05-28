import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 在文本编辑器状态没有内容的时候，这个用来作为默认的输入
///
/// 目前用法有错
class BaselineProxy extends SingleChildRenderObjectWidget {
  const BaselineProxy({Key? key, Widget? child, this.textStyle, this.padding})
      : super(key: key, child: child);

  final TextStyle? textStyle;
  /// 垂直间距
  final EdgeInsetsGeometry? padding;

  @override
  RenderBaselineProxy createRenderObject(BuildContext context) {
    return RenderBaselineProxy(
      null,
      textStyle!,
      padding,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderBaselineProxy renderObject) {
    renderObject
      ..textStyle = textStyle!
      ..padding = padding!;
  }
}

/// 渲染代理
class RenderBaselineProxy extends RenderProxyBox {
  RenderBaselineProxy(
    RenderParagraph? child,
    TextStyle textStyle,
    EdgeInsetsGeometry? padding,
  )   : _prototypePainter = TextPainter(
          text: TextSpan(text: ' ', style: textStyle),
          textDirection: TextDirection.ltr,
          strutStyle:
              StrutStyle.fromTextStyle(textStyle, forceStrutHeight: true),
        ),
        super(child);

  /// 文本绘制器
  final TextPainter _prototypePainter;

  /// 设置一个空的文本， 并且给与文本样式
  set textStyle(TextStyle value) {
    if (_prototypePainter.text!.style == value) {
      return;
    }
    _prototypePainter.text = TextSpan(text: ' ', style: value);
    markNeedsLayout();
  }

  EdgeInsetsGeometry? _padding;

  set padding(EdgeInsetsGeometry value) {
    if (_padding == value) {
      return;
    }
    _padding = value;
    markNeedsLayout();
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) =>
      _prototypePainter.computeDistanceToActualBaseline(baseline);

  @override
  void performLayout() {
    super.performLayout();
    _prototypePainter.layout();
  }
}

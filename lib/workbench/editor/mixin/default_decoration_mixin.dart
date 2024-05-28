import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 可编辑容器的一些装饰
///
mixin EditorDecorationMixin on RenderBox {
  void initDecoration({
    TextDirection? textDirection,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? paddingMain,
    EdgeInsetsGeometry? paddingMinor,
    Decoration? decoration,
    ImageConfiguration? imageConfiguration,
    Decoration? selectedDecoration,
  }) {
    _textDirection = textDirection ?? TextDirection.ltr;
    _margin = margin;
    this.paddingMain = paddingMain;
    this.paddingMinor = paddingMinor;
    _decoration = decoration;
    _imageConfiguration =
        imageConfiguration ?? ImageConfiguration(textDirection: textDirection);
    _selectedDecoration = _selectedDecoration;
  }

  /// 文本方向
  TextDirection _textDirection = TextDirection.ltr;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
  }

  /// 主要的padding, 一定会存在
  EdgeInsetsGeometry? _paddingMain;
  EdgeInsetsGeometry? get paddingMain => _paddingMain;
  set paddingMain(EdgeInsetsGeometry? value) {
    if (_paddingMain == value) return;
    _paddingMain = value;
    padding = (value ?? EdgeInsets.zero).add(_paddingMinor ?? EdgeInsets.zero);
  }

  /// 次要的， 不一定会存在
  EdgeInsetsGeometry? _paddingMinor;
  EdgeInsetsGeometry? get paddingMinor => _paddingMinor;
  set paddingMinor(EdgeInsetsGeometry? value) {
    if (_paddingMinor == value) return;
    _paddingMinor = value;
    padding =  (value ?? EdgeInsets.zero).add(_paddingMain ?? EdgeInsets.zero);
  }

  /// 真正的内边距大小
  EdgeInsetsGeometry? _padding;
  EdgeInsetsGeometry? get padding => _padding;
  set padding(EdgeInsetsGeometry? value) {
    assert(value!.isNonNegative);
    if (_padding == value) {
      return;
    }
    _padding = value;
    markNeedsPaddingResolution();
  }

  /// 任意的内边距被设置，都会导致需要重新处理内边距
  void markNeedsPaddingResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  /// 处理过后边距大小
  EdgeInsets? _resolvedPadding;
  EdgeInsets? get resolvedPadding => _resolvedPadding;
  void resolvePadding() {
    if (_resolvedPadding != null) {
      return;
    }
    _resolvedPadding = _padding!.resolve(_textDirection);
    assert(_resolvedPadding!.isNonNegative);
  }

  /// 外边距大小
  EdgeInsetsGeometry? _margin;
  EdgeInsetsGeometry? get margin => _margin;
  set margin(EdgeInsetsGeometry? value) {
    assert(value!.isNonNegative);
    if (_margin == value) {
      return;
    }
    _margin = value;
    markNeedsPaddingResolution();
  }

  /// 边框装饰器
  Decoration? _decoration;
  Decoration? get decoration => _decoration;
  set decoration(Decoration? value) {
    if (value == _decoration) return;
    _decorationPainter?.dispose();
    _decorationPainter = null;
    _decoration = value;
    markNeedsPaint();
  }

  /// 选择装饰器
  Decoration? _selectedDecoration;
  Decoration? get selectedDecoration => _selectedDecoration;
  set selectedDecoration(Decoration? value) {
    if (value == _selectedDecoration) return;
    _selectionDecorationPainter?.dispose();
    _selectionDecorationPainter = null;
    _selectedDecoration = value;
    markNeedsPaint();
  }

  /// 绘制图片的配置， 一般只需要设置填充的大小即可
  ImageConfiguration? _imageConfiguration;
  ImageConfiguration? get imageConfiguration => _imageConfiguration;
  set imageConfiguration(ImageConfiguration? value) {
    if (value == _imageConfiguration) return;
    _imageConfiguration = value;
    markNeedsPaint();
  }

  void defaultPaintDecoration(
      PaintingContext context, Offset offset, bool isBorder) {
    paintDecoration(context, offset);
    if (isBorder) {
      paintSelectionDecoration(context, offset);
    }
  }

  /// 绘制边框, offset 相对于这个绘制对象的偏移
  BoxPainter? _decorationPainter;

  void paintDecoration(PaintingContext context, Offset offset) {
    if (_decoration == null) {
      return;
    }
    _decorationPainter ??= _decoration!.createBoxPainter(markNeedsPaint);

    final filledConfiguration = imageConfiguration!.copyWith(size: size);
    final debugSaveCount = context.canvas.getSaveCount();

    _decorationPainter!.paint(context.canvas, offset, filledConfiguration);
    if (debugSaveCount != context.canvas.getSaveCount()) {
      throw '${_decoration.runtimeType} painter had mismatching save and restore calls.';
    }
    if (_decoration!.isComplex) {
      context.setIsComplexHint();
    }
  }

  /// 绘制选择的边框
  BoxPainter? _selectionDecorationPainter;

  void paintSelectionDecoration(PaintingContext context, Offset offset) {
    if (_selectedDecoration == null) {
      return;
    }
    // 绘制器
    _selectionDecorationPainter ??=
        _selectedDecoration!.createBoxPainter(markNeedsPaint);
    const decorationPadding = EdgeInsets.zero;
    // 图片 缩小尺寸
    final filledConfiguration =
        imageConfiguration!.copyWith(size: decorationPadding.deflateSize(size));

    final debugSaveCount = context.canvas.getSaveCount();
    final decorationOffset =
        offset.translate(decorationPadding.left, decorationPadding.top);
    // 绘制
    _selectionDecorationPainter!
        .paint(context.canvas, decorationOffset, filledConfiguration);
    if (debugSaveCount != context.canvas.getSaveCount()) {
      throw '${_decoration.runtimeType} painter had mismatching save and restore calls.';
    }
    if (_decoration!.isComplex) {
      context.setIsComplexHint();
    }
  }

  @override
  void detach() {
    _decorationPainter?.dispose();
    _decorationPainter = null;
    _selectionDecorationPainter?.dispose();
    _selectionDecorationPainter = null;
    super.detach();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Decoration>('kDecoration', decoration));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('kMargin', margin));
    properties
        .add(DiagnosticsProperty<EdgeInsetsGeometry>('kPadding', padding));
    properties
        .add(DiagnosticsProperty<EdgeInsetsGeometry>('kPaddingMain', paddingMain));
    properties
        .add(DiagnosticsProperty<EdgeInsetsGeometry>('kPaddingMinor', paddingMinor));
  }
}

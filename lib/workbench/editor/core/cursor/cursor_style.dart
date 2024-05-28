import 'package:flutter/widgets.dart';


///光标样式配置
class CursorStyle {
  const CursorStyle({
    required this.color,
    required this.backgroundColor,
    this.width = 1.0,
    this.height,
    this.radius,
    this.offset,
    this.opacityAnimates = false,
    this.paintAboveText = false,
  });

  /// 光标颜色
  final Color color;

  /// 光标背景色
  final Color backgroundColor;

  /// 光标宽
  final double width;

  /// 光标高度
  final double? height;

  /// 光标矩形的圆角半径
  final Radius? radius;

  /// 偏移
  final Offset? offset;

  /// 闪烁时动画带透明效果
  final bool opacityAnimates;

  /// 绘制在文本之上
  final bool paintAboveText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CursorStyle &&
              runtimeType == other.runtimeType &&
              color == other.color &&
              backgroundColor == other.backgroundColor &&
              width == other.width &&
              height == other.height &&
              radius == other.radius &&
              offset == other.offset &&
              opacityAnimates == other.opacityAnimates &&
              paintAboveText == other.paintAboveText;

  @override
  int get hashCode =>
      color.hashCode ^
      backgroundColor.hashCode ^
      width.hashCode ^
      height.hashCode ^
      radius.hashCode ^
      offset.hashCode ^
      opacityAnimates.hashCode ^
      paintAboveText.hashCode;
}

import 'package:flutter/material.dart';

class EditorIconTheme {
  const EditorIconTheme({
    this.iconSelectedColor,
    this.iconUnselectedColor,
    this.iconSelectedFillColor,
    this.iconUnselectedFillColor,
    this.disabledIconColor,
    this.disabledIconFillColor,
  });

  /// 工具栏中选定图标的颜色
  final Color? iconSelectedColor;

  /// 工具栏中选定图标的颜色
  final Color? iconUnselectedColor;

  /// 工具栏中选定图标的颜色
  final Color? iconSelectedFillColor;

  /// 工具栏中未选中图标的填充颜色
  final Color? iconUnselectedFillColor;

  /// 工具栏中禁用图标的颜色
  final Color? disabledIconColor;

  /// 工具栏中禁用图标的颜色
  final Color? disabledIconFillColor;
}

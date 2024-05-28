import 'package:flutter/material.dart';

class EditorDialogTheme {
  EditorDialogTheme(
      {this.labelTextStyle, this.inputTextStyle, this.dialogBackgroundColor});

  /// 用于链接输入对话框中显示的标签的文本样式
  final TextStyle? labelTextStyle;

  /// 用于链接输入对话框中显示的输入文本的文本样式
  final TextStyle? inputTextStyle;

  /// [LinkDialog]的背景颜色
  final Color? dialogBackgroundColor;
}

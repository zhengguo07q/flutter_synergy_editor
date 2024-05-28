import 'package:flutter/cupertino.dart';

/// 内部使用，用于获取拖动方向信息
class TextSelectionDrag extends TextSelection {
  const TextSelectionDrag({
    TextAffinity affinity = TextAffinity.downstream,
    int baseOffset = 0,
    int extentOffset = 0,
    bool isDirectional = false,
    this.first = true,
  }) : super(
          baseOffset: baseOffset,
          extentOffset: extentOffset,
          affinity: affinity,
          isDirectional: isDirectional,
        );

  final bool first;

  @override
  TextSelectionDrag copyWith({
    int? baseOffset,
    int? extentOffset,
    TextAffinity? affinity,
    bool? isDirectional,
    bool? first,
  }) {
    return TextSelectionDrag(
      baseOffset: baseOffset ?? this.baseOffset,
      extentOffset: extentOffset ?? this.extentOffset,
      affinity: affinity ?? this.affinity,
      isDirectional: isDirectional ?? this.isDirectional,
      first: first ?? this.first,
    );
  }
}

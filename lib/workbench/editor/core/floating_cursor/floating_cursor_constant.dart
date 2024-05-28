import 'package:flutter/rendering.dart';

///浮动光标的光标绘制半径
const Radius kFloatingCaretRadius = Radius.circular(1);

/// 填充应用于文本字段。用于确定移动浮动游标时的边界。
const EdgeInsets kFloatingCursorAddedMargin = EdgeInsets.fromLTRB(4, 4, 4, 5);

/// 在x和y轴上扩展原型游标以渲染浮点游标的附加大小。
const EdgeInsets kFloatingCaretSizeIncrease =
    EdgeInsets.symmetric(horizontal: 0.5, vertical: 1);

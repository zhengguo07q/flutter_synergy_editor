import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../core/box.dart';
import '../core/cursor/cursor_controller.dart';

mixin ComponentRenderMixin on RenderEditableBox {
  late CursorController cursorCont;
  Rect? caretPrototype;

  double get cursorWidth => cursorCont.style.width;

  double get cursorHeight =>
      cursorCont.style.height ??
          preferredLineHeight(const TextPosition(offset: 0));

  void computeCaretPrototype() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        caretPrototype = Rect.fromLTWH(0, 0, cursorWidth, cursorHeight + 2);
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        caretPrototype = Rect.fromLTWH(0, 2, cursorWidth, cursorHeight - 4.0);
        break;
      default:
        throw 'Invalid platform';
    }
  }

  void setCursorCont(CursorController c) {
    if (cursorCont == c) {
      return;
    }
    cursorCont = c;
    markNeedsLayout();
  }
}

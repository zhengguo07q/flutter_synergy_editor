import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 键盘访问组件
class KeyboardPressedKeysAccess extends InheritedWidget {
  const KeyboardPressedKeysAccess({
    required this.pressedKeys,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  final KeyboardPressedKeysNotifier pressedKeys;

  @override
  bool updateShouldNotify(covariant KeyboardPressedKeysAccess oldWidget) {
    return oldWidget.pressedKeys != pressedKeys;
  }
}

class KeyboardPressedKeysNotifier extends ChangeNotifier {
  static KeyboardPressedKeysNotifier of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<KeyboardPressedKeysAccess>();
    return widget!.pressedKeys;
  }

  bool _metaPressed = false;
  bool _controlPressed = false;

  /// 当前是否按下元键。
  bool get metaPressed => _metaPressed;

  /// 当前是否按下控制键。
  bool get controlPressed => _controlPressed;

  void updatePressedKeys(Set<LogicalKeyboardKey> pressedKeys) {
    final meta = pressedKeys.contains(LogicalKeyboardKey.metaLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.metaRight);
    final control = pressedKeys.contains(LogicalKeyboardKey.controlLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.controlRight);
    if (_metaPressed != meta || _controlPressed != control) {
      _metaPressed = meta;
      _controlPressed = control;
      notifyListeners();
    }
  }
}

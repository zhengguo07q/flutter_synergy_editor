import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'keyboard_pressed_keys.dart';

/// 自定义键盘访问组件, 内部组件监听键盘所用
class KeyboardListener extends StatefulWidget {
  const KeyboardListener({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  KeyboardListenerState createState() => KeyboardListenerState();
}

class KeyboardListenerState extends State<KeyboardListener> {
  final KeyboardPressedKeysNotifier _pressedKeys =
      KeyboardPressedKeysNotifier();

  bool _keyEvent(KeyEvent event) {
    _pressedKeys
        .updatePressedKeys(HardwareKeyboard.instance.logicalKeysPressed);
    return false;
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_keyEvent);
    _pressedKeys
        .updatePressedKeys(HardwareKeyboard.instance.logicalKeysPressed);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyEvent);
    _pressedKeys.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardPressedKeysAccess(
      pressedKeys: _pressedKeys,
      child: widget.child,
    );
  }
}

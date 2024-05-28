import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

bool isMobile([TargetPlatform? targetPlatform]) {
  targetPlatform ??= defaultTargetPlatform;
  return {TargetPlatform.iOS, TargetPlatform.android}.contains(targetPlatform);
}

bool isDesktop([TargetPlatform? targetPlatform]) {
  targetPlatform ??= defaultTargetPlatform;
  return {TargetPlatform.macOS, TargetPlatform.linux, TargetPlatform.windows}
      .contains(targetPlatform);
}

/// 判断是否带键盘的操作系统
///
/// 桌面操作系统， fuchsia都属于自己带键盘的操作系统
bool isKeyboardOS([TargetPlatform? targetPlatform]) {
  targetPlatform ??= defaultTargetPlatform;
  return isDesktop(targetPlatform) || targetPlatform == TargetPlatform.fuchsia;
}

bool isAppleOS([TargetPlatform? targetPlatform]) {
  targetPlatform ??= defaultTargetPlatform;
  return {
    TargetPlatform.macOS,
    TargetPlatform.iOS,
  }.contains(targetPlatform);
}

Future<bool> isIOSSimulator() async {
  if (Platform.isIOS) {
    final deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;
    return !iosInfo.isPhysicalDevice;
  }
  return false;
}

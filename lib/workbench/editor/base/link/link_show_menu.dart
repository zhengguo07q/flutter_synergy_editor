import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slate/slate.dart';

import 'link_action_platform.dart';
import 'link_config.dart';


Future<LinkMenuAction> linkActionPicker(BuildContext context, Node linkNode) async {
  final link = linkNode.attributes[AttributeRegister.link.key]!.value!;
  return linkActionPickerDelegate(context, link, linkNode);
}

/// 默认的链接菜单的动作委派， 调用一个modalPopup
Future<LinkMenuAction> linkActionPickerDelegate(
    BuildContext context, String link, Node node) async {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return showCupertinoLinkMenu(context, link);
    case TargetPlatform.android:
      return showMaterialMenu(context, link);
    default:
      assert(
      false,
      'defaultShowLinkActionsMenu not supposed to '
          'be invoked for $defaultTargetPlatform');
      return LinkMenuAction.none;
  }
}

/// IOS平台显示链接菜单
Future<LinkMenuAction> showCupertinoLinkMenu(
    BuildContext context, String link) async {
  final result = await showCupertinoModalPopup<LinkMenuAction>(
    context: context,
    builder: (ctx) {
      return CupertinoActionSheet(
        title: Text(link),
        actions: [
          CupertinoAction(
            title: 'Open',
            icon: Icons.language_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.launch),
          ),
          CupertinoAction(
            title: 'Copy',
            icon: Icons.copy_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.copy),
          ),
          CupertinoAction(
            title: 'Remove',
            icon: Icons.link_off_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.remove),
          ),
        ],
      );
    },
  );
  return result ?? LinkMenuAction.none;
}

/// 其他平台显示链接菜单
Future<LinkMenuAction> showMaterialMenu(
    BuildContext context, String link) async {
  final result = await showModalBottomSheet<LinkMenuAction>(
    context: context,
    builder: (ctx) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MaterialAction(
            title: 'Open',
            icon: Icons.language_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.launch),
          ),
          MaterialAction(
            title: 'Copy',
            icon: Icons.copy_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.copy),
          ),
          MaterialAction(
            title: 'Remove',
            icon: Icons.link_off_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.remove),
          ),
        ],
      );
    },
  );

  return result ?? LinkMenuAction.none;
}
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/updater/text_holder.dart';

import '../../updater/dirty_updater.dart';
import '../../updater/document_controller.dart';
import '../_config.dart';
import '../theme/editor_icon_button.dart';
import '../util/image_video_utils.dart';
import '../theme/editor_icon_theme.dart';
import '../theme/editor_dialog_theme.dart';
import '../toolbar.dart';

class ImageButton extends StatelessWidget {
  const ImageButton({
    required this.icon,
    required this.dirtyUpdater,
    this.iconSize = kDefaultIconSize,
    this.onImagePickCallback,
    this.fillColor,
    this.filePickImpl,
    this.webImagePickImpl,
    this.mediaPickSettingSelector,
    this.iconTheme,
    this.dialogTheme,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final Color? fillColor;

  final DirtyUpdater dirtyUpdater;

  final OnImagePickCallback? onImagePickCallback;

  final WebImagePickImpl? webImagePickImpl;

  final FilePickImpl? filePickImpl;

  final MediaPickSettingSelector? mediaPickSettingSelector;

  final EditorIconTheme? iconTheme;

  final EditorDialogTheme? dialogTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? (fillColor ?? theme.canvasColor);

    return EditorIconButton(
      icon: Icon(icon, size: iconSize, color: iconColor),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      onPressed: () => _onPressedHandler(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    if (onImagePickCallback != null) {
      final selector =
          mediaPickSettingSelector ?? ImageVideoUtils.selectMediaPickSetting;
      final source = await selector(context);
      if (source != null) {
        if (source == MediaPickSetting.Gallery) {
          _pickImage(context);
        } else {
          _typeLink(context);
        }
      }
    } else {
      _typeLink(context);
    }
  }

  void _pickImage(BuildContext context) => ImageVideoUtils.handleImageButtonTap(
        context,
        dirtyUpdater,
        ImageSource.gallery,
        onImagePickCallback!,
        filePickImpl: filePickImpl,
        webImagePickImpl: webImagePickImpl,
      );

  void _typeLink(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (_) => LinkDialog(dialogTheme: dialogTheme),
    ).then(_linkSubmitted);
  }

  void _linkSubmitted(String? value) {
    if (value != null && value.isNotEmpty) {
      // final index = controller.selection.baseOffset;
      // final length = controller.selection.extentOffset - index;
      //
      // controller.replaceText(index, length, BlockEmbed.image(value), null);
      // NodeTransforms.setNodes(controller.document, props)
    }
  }
}

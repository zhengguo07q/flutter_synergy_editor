import 'dart:io';

import 'package:flutter/material.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/toolbar/theme/editor_icon_theme.dart';
import 'package:thinkhub_client/workbench/toolbar/theme/editor_dialog_theme.dart';

import '../updater/dirty_updater.dart';
import '_config.dart';
import 'arrow_indicated_button_list.dart';
import 'button/camera_button.dart';
import 'button/clear_format_button.dart';
import 'button/color_button.dart';
import 'button/image_button.dart';
import 'button/indent_button.dart';
import 'button/link_style_button.dart';
import 'button/select_alignment_button.dart';
import 'button/select_header_style_button.dart';
import 'button/toggle_check_list_button.dart';
import 'button/toggle_style_button.dart';
import 'button/video_button.dart';
import 'util/image_video_utils.dart';

typedef OnImagePickCallback = Future<String?> Function(File file);
typedef OnVideoPickCallback = Future<String?> Function(File file);
typedef FilePickImpl = Future<String?> Function(BuildContext context);
typedef WebImagePickImpl = Future<String?> Function(
    OnImagePickCallback onImagePickCallback);
typedef WebVideoPickImpl = Future<String?> Function(
    OnVideoPickCallback onImagePickCallback);
typedef MediaPickSettingSelector = Future<MediaPickSetting?> Function(
    BuildContext context);

class EditorToolbar extends StatelessWidget implements PreferredSizeWidget {
  const EditorToolbar({
    required this.children,
    this.toolbarHeight = 36,
    this.toolbarIconAlignment = WrapAlignment.center,
    this.toolbarSectionSpacing = 4,
    this.multiRowsDisplay = true,
    this.color,
    this.filePickImpl,
    this.locale,
    Key? key,
  }) : super(key: key);

  factory EditorToolbar.basic({
    required DirtyUpdater dirtyUpdater,
    double toolbarIconSize = kDefaultIconSize,
    double toolbarSectionSpacing = 4,
    WrapAlignment toolbarIconAlignment = WrapAlignment.center,
    bool showDividers = true,
    bool showBoldButton = true,
    bool showItalicButton = true,
    bool showSmallButton = false,
    bool showUnderLineButton = true,
    bool showStrikeThrough = true,
    bool showInlineCode = true,
    bool showColorButton = true,
    bool showBackgroundColorButton = true,
    bool showClearFormat = true,
    bool showAlignmentButtons = false,
    bool showLeftAlignment = true,
    bool showCenterAlignment = true,
    bool showRightAlignment = true,
    bool showJustifyAlignment = true,
    bool showHeaderStyle = true,
    bool showListNumbers = true,
    bool showListBullets = true,
    bool showListCheck = true,
    bool showCodeBlock = true,
    bool showQuote = true,
    bool showIndent = true,
    bool showLink = true,
    bool multiRowsDisplay = true,
    bool showImageButton = true,
    bool showVideoButton = true,
    bool showCameraButton = true,
    bool showDirection = false,
    OnImagePickCallback? onImagePickCallback,
    OnVideoPickCallback? onVideoPickCallback,
    MediaPickSettingSelector? mediaPickSettingSelector,
    FilePickImpl? filePickImpl,
    WebImagePickImpl? webImagePickImpl,
    WebVideoPickImpl? webVideoPickImpl,

    ///The theme to use for the icons in the toolbar, uses type [QuillIconTheme]
    EditorIconTheme? iconTheme,

    ///The theme to use for the theming of the [LinkDialog()],
    ///shown when embedding an image, for example
    EditorDialogTheme? dialogTheme,

    /// The locale to use for the editor toolbar, defaults to system locale
    /// More at https://github.com/singerdmx/flutter-quill#translation
    Locale? locale,
    Key? key,
  }) {
    final isButtonGroupShown = [
      showBoldButton ||
          showItalicButton ||
          showSmallButton ||
          showUnderLineButton ||
          showStrikeThrough ||
          showInlineCode ||
          showColorButton ||
          showBackgroundColorButton ||
          showClearFormat ||
          onImagePickCallback != null ||
          onVideoPickCallback != null,
      showAlignmentButtons || showDirection,
      showLeftAlignment,
      showCenterAlignment,
      showRightAlignment,
      showJustifyAlignment,
      showHeaderStyle,
      showListNumbers || showListBullets || showListCheck || showCodeBlock,
      showQuote || showIndent,
      showLink
    ];

    return EditorToolbar(
      key: key,
      toolbarHeight: toolbarIconSize * 2,
      toolbarSectionSpacing: toolbarSectionSpacing,
      toolbarIconAlignment: toolbarIconAlignment,
      multiRowsDisplay: multiRowsDisplay,
      locale: locale,
      children: [
        if (showBoldButton)
          // 加粗
          ToggleStyleButton(
            attribute: AttributeRegister.bold,
            icon: Icons.format_bold,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            iconTheme: iconTheme,
          ),
        if (showItalicButton)
          // 斜体
          ToggleStyleButton(
            attribute: AttributeRegister.italic,
            icon: Icons.format_italic,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            iconTheme: iconTheme,
          ),
        if (showSmallButton)
          // 变小
          ToggleStyleButton(
            attribute: AttributeRegister.small,
            icon: Icons.format_size,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            iconTheme: iconTheme,
          ),
        if (showUnderLineButton)
          // 下划线
          ToggleStyleButton(
            attribute: AttributeRegister.underline,
            icon: Icons.format_underline,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            iconTheme: iconTheme,
          ),
        if (showStrikeThrough)
          // 删除线
          ToggleStyleButton(
            attribute: AttributeRegister.strikeThrough,
            icon: Icons.format_strikethrough,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            iconTheme: iconTheme,
          ),
        if (showInlineCode)
          ToggleStyleButton(
            attribute: AttributeRegister.inlineCode,
            icon: Icons.code,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            iconTheme: iconTheme,
          ),
        if (showColorButton)
          ColorButton(
            icon: Icons.color_lens,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            background: false,
            iconTheme: iconTheme,
          ),
        if (showBackgroundColorButton)
          ColorButton(
            icon: Icons.format_color_fill,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            background: true,
            iconTheme: iconTheme,
          ),
        if (showClearFormat)
          ClearFormatButton(
            icon: Icons.format_clear,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            iconTheme: iconTheme,
          ),
        if (showImageButton)
          ImageButton(
            icon: Icons.image,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            onImagePickCallback: onImagePickCallback,
            filePickImpl: filePickImpl,
            webImagePickImpl: webImagePickImpl,
            mediaPickSettingSelector: mediaPickSettingSelector,
            iconTheme: iconTheme,
            dialogTheme: dialogTheme,
          ),
        if (showVideoButton)
          VideoButton(
            icon: Icons.movie_creation,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            onVideoPickCallback: onVideoPickCallback,
            filePickImpl: filePickImpl,
            webVideoPickImpl: webImagePickImpl,
            mediaPickSettingSelector: mediaPickSettingSelector,
            iconTheme: iconTheme,
            dialogTheme: dialogTheme,
          ),
        if ((onImagePickCallback != null || onVideoPickCallback != null) &&
            showCameraButton)
          CameraButton(
            icon: Icons.photo_camera,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            onImagePickCallback: onImagePickCallback,
            onVideoPickCallback: onVideoPickCallback,
            filePickImpl: filePickImpl,
            webImagePickImpl: webImagePickImpl,
            webVideoPickImpl: webVideoPickImpl,
            iconTheme: iconTheme,
          ),
        if (showDividers &&
            isButtonGroupShown[0] &&
            (isButtonGroupShown[1] ||
                isButtonGroupShown[2] ||
                isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: Colors.grey.shade400,
          ),
        if (showAlignmentButtons)
          SelectAlignmentButton(
            dirtyUpdater: dirtyUpdater,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
            showLeftAlignment: showLeftAlignment,
            showCenterAlignment: showCenterAlignment,
            showRightAlignment: showRightAlignment,
            showJustifyAlignment: showJustifyAlignment,
          ),
        if (showDirection)
          ToggleStyleButton(
            attribute: AttributeRegister.rtl,
            dirtyUpdater: dirtyUpdater,
            icon: Icons.format_textdirection_r_to_l,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
          ),
        if (showDividers &&
            isButtonGroupShown[1] &&
            (isButtonGroupShown[2] ||
                isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: Colors.grey.shade400,
          ),
        if (showHeaderStyle)
          SelectHeaderStyleButton(
            dirtyUpdater: dirtyUpdater,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
          ),
        if (showDividers &&
            showHeaderStyle &&
            isButtonGroupShown[2] &&
            (isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: Colors.grey.shade400,
          ),
        if (showListNumbers)
          ToggleStyleButton(
            attribute: AttributeRegister.ol,
            dirtyUpdater: dirtyUpdater,
            icon: Icons.format_list_numbered,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
          ),
        if (showListBullets)
          ToggleStyleButton(
            attribute: AttributeRegister.ul,
            dirtyUpdater: dirtyUpdater,
            icon: Icons.format_list_bulleted,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
          ),
        if (showListCheck)
          ToggleCheckListButton(
            attribute: AttributeRegister.unchecked,
            dirtyUpdater: dirtyUpdater,
            icon: Icons.check_box,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
          ),
        if (showCodeBlock)
          ToggleStyleButton(
            attribute: AttributeRegister.codeBlock,
            dirtyUpdater: dirtyUpdater,
            icon: Icons.code,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
          ),
        if (showDividers &&
            isButtonGroupShown[3] &&
            (isButtonGroupShown[4] || isButtonGroupShown[5]))
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: Colors.grey.shade400,
          ),
        if (showQuote)
          ToggleStyleButton(
            attribute: AttributeRegister.blockQuote,
            dirtyUpdater: dirtyUpdater,
            icon: Icons.format_quote,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
          ),
        if (showIndent)
          IndentButton(
            icon: Icons.format_indent_increase,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            isIncrease: true,
            iconTheme: iconTheme,
          ),
        if (showIndent)
          IndentButton(
            icon: Icons.format_indent_decrease,
            iconSize: toolbarIconSize,
            dirtyUpdater: dirtyUpdater,
            isIncrease: false,
            iconTheme: iconTheme,
          ),
        if (showDividers && isButtonGroupShown[4] && isButtonGroupShown[5])
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: Colors.grey.shade400,
          ),
        if (false)
          LinkStyleButton(
            dirtyUpdater: dirtyUpdater,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
            dialogTheme: dialogTheme,
          ),
      ],
    );
  }

  final List<Widget> children;
  final double toolbarHeight;
  final double toolbarSectionSpacing;
  final WrapAlignment toolbarIconAlignment;
  final bool multiRowsDisplay;

  /// The color of the toolbar.
  ///
  /// Defaults to [ThemeData.canvasColor] of the current [Theme] if no color
  /// is given.
  final Color? color;

  final FilePickImpl? filePickImpl;

  /// The locale to use for the editor toolbar, defaults to system locale
  /// More https://github.com/singerdmx/flutter-quill#translation
  final Locale? locale;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return multiRowsDisplay
        ? Wrap(
            alignment: toolbarIconAlignment,
            runSpacing: 4,
            spacing: toolbarSectionSpacing,
            children: children,
          )
        : Container(
            constraints: BoxConstraints.tightFor(height: preferredSize.height),
            color: color ?? Theme.of(context).canvasColor,
            child: ArrowIndicatedButtonList(buttons: children),
          );
  }
}

import 'dart:math' as math;

import 'package:common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:thinkhub_client/workbench/editor/main/editor_abstract.dart';

enum TextSelectionHandlePosition { start, end }

/// 选区手柄绘制
class TextSelectionHandleOverlay extends StatefulWidget {
  const TextSelectionHandleOverlay({
    required this.selection,
    required this.position,
    required this.startHandleLayerLink,
    required this.endHandleLayerLink,
    required this.renderObject,
    required this.onSelectionHandleChanged,
    required this.onSelectionHandleTapped,
    required this.selectionControls,
    this.dragStartBehavior = DragStartBehavior.start,
    Key? key,
  }) : super(key: key);

  final TextSelection selection;

  /// 当前绘制的选区位置
  final TextSelectionHandlePosition position;

  /// 选区开始的链接位置
  final LayerLink startHandleLayerLink;

  /// 选区结束的链接位置
  final LayerLink endHandleLayerLink;

  /// 渲染对象引用
  final AbstractEditorRenderBox? renderObject;
  final ValueChanged<TextSelection?> onSelectionHandleChanged;
  final VoidCallback? onSelectionHandleTapped;

  /// 选区控制器构建
  final TextSelectionControls selectionControls;
  final DragStartBehavior dragStartBehavior;

  @override
  _TextSelectionHandleOverlayState createState() =>
      _TextSelectionHandleOverlayState();

  /// 手柄的可见性
  ///
  /// 有可能超出编辑器边界，需要做可见性判断
  ValueListenable<bool>? get _visibility {
    switch (position) {
      case TextSelectionHandlePosition.start:
        return renderObject!.textPositionPart.selectionStartInViewport;
      case TextSelectionHandlePosition.end:
        return renderObject!.textPositionPart.selectionEndInViewport;
    }
  }
}

class _TextSelectionHandleOverlayState extends State<TextSelectionHandleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Animation<double> get _opacity => _controller.view;
  late Offset _dragPosition;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);

    _handleVisibilityChanged();
    widget._visibility!.addListener(_handleVisibilityChanged);
  }

  void _handleVisibilityChanged() {
    if (widget._visibility!.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(TextSelectionHandleOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget._visibility!.removeListener(_handleVisibilityChanged);
    _handleVisibilityChanged();
    widget._visibility!.addListener(_handleVisibilityChanged);
  }

  @override
  void dispose() {
    widget._visibility!.removeListener(_handleVisibilityChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    final textPosition = widget.position == TextSelectionHandlePosition.start
        ? widget.selection.base
        : widget.selection.extent;
    final lineHeight =
        widget.renderObject!.textPositionPart.preferredLineHeight(textPosition);
    final handleSize = widget.selectionControls.getHandleSize(lineHeight);
    _dragPosition = details.globalPosition + Offset(0, -handleSize.height);
  }

  /// 拖动手柄事件
  void _handleDragUpdate(DragUpdateDetails details) {
    _dragPosition += details.delta;
    //  AppLogger.selectionLog.i('_dragPosition $_dragPosition');
    final position = widget.renderObject!.textPositionPart
        .getPositionForOffset(_dragPosition);
    if (widget.selection.isCollapsed) {
      widget.onSelectionHandleChanged(TextSelection.fromPosition(position));
      return;
    }

    final isNormalized =
        widget.selection.extentOffset >= widget.selection.baseOffset;
    TextSelection? newSelection;
    switch (widget.position) {
      case TextSelectionHandlePosition.start:
        newSelection = TextSelection(
          baseOffset:
              isNormalized ? position.offset : widget.selection.baseOffset,
          extentOffset:
              isNormalized ? widget.selection.extentOffset : position.offset,
        );
        break;
      case TextSelectionHandlePosition.end:
        newSelection = TextSelection(
          baseOffset:
              isNormalized ? widget.selection.baseOffset : position.offset,
          extentOffset:
              isNormalized ? position.offset : widget.selection.extentOffset,
        );
        break;
    }

    if (newSelection.baseOffset >= newSelection.extentOffset) {
      return; // don't allow order swapping.
    }

    widget.onSelectionHandleChanged(newSelection);
  }

  /// 点击拖动手柄
  void _handleTap() {
    if (widget.onSelectionHandleTapped != null) {
      widget.onSelectionHandleTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    late LayerLink layerLink;
    TextSelectionHandleType? type;

    switch (widget.position) {
      case TextSelectionHandlePosition.start:
        layerLink = widget.startHandleLayerLink;
        type = _chooseType(
          widget.renderObject!.textDirection,
          TextSelectionHandleType.left,
          TextSelectionHandleType.right,
        );
        break;
      case TextSelectionHandlePosition.end:
        assert(!widget.selection.isCollapsed);
        layerLink = widget.endHandleLayerLink;
        type = _chooseType(
          widget.renderObject!.textDirection,
          TextSelectionHandleType.right,
          TextSelectionHandleType.left,
        );
        break;
    }

    final textPosition = widget.position == TextSelectionHandlePosition.start
        ? widget.selection.base
        : widget.selection.extent;
    final lineHeight =
        widget.renderObject!.textPositionPart.preferredLineHeight(textPosition);
    final handleAnchor =
        widget.selectionControls.getHandleAnchor(type!, lineHeight);
    final handleSize = widget.selectionControls.getHandleSize(lineHeight);

    final handleRect = Rect.fromLTWH(
      -handleAnchor.dx,
      -handleAnchor.dy,
      handleSize.width,
      handleSize.height,
    );

    final interactiveRect = handleRect.expandToInclude(
      Rect.fromCircle(
          center: handleRect.center, radius: kMinInteractiveDimension / 2),
    );
    final padding = RelativeRect.fromLTRB(
      math.max((interactiveRect.width - handleRect.width) / 2, 0),
      math.max((interactiveRect.height - handleRect.height) / 2, 0),
      math.max((interactiveRect.width - handleRect.width) / 2, 0),
      math.max((interactiveRect.height - handleRect.height) / 2, 0),
    );

    return CompositedTransformFollower(
      link: layerLink,
      offset: interactiveRect.topLeft,
      showWhenUnlinked: false,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          alignment: Alignment.topLeft,
          width: interactiveRect.width,
          height: interactiveRect.height,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            dragStartBehavior: widget.dragStartBehavior,
            onPanStart: _handleDragStart,
            onPanUpdate: _handleDragUpdate,
            onTap: _handleTap,
            child: Padding(
              padding: EdgeInsets.only(
                left: padding.left,
                top: padding.top,
                right: padding.right,
                bottom: padding.bottom,
              ),
              // 调用系统的选择控制器来绘制
              child: widget.selectionControls.buildHandle(
                context,
                type,
                lineHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextSelectionHandleType? _chooseType(
    TextDirection textDirection,
    TextSelectionHandleType ltrType,
    TextSelectionHandleType rtlType,
  ) {
    if (widget.selection.isCollapsed) return TextSelectionHandleType.collapsed;

    switch (textDirection) {
      case TextDirection.ltr:
        return ltrType;
      case TextDirection.rtl:
        return rtlType;
    }
  }
}

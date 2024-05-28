import 'dart:async';

import 'package:common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide KeyboardListener;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:thinkhub_client/workbench/updater/dirty_updater.dart';

import '../../updater/text_holder.dart';
import '../core/floating_cursor/floating_cursor_update.dart';
import 'editor_abstract.dart';
import '../../util/platform.dart';
import '../base/builder_block.dart';
import '../base/style/style_default.dart';
import '../base/style/style_widget.dart';
import '../core/cursor/cursor_controller.dart';
import '../core/cursor/cursor_style.dart';
import '../core/keyboard/keyboard_listener.dart';
import '../core/text/action_instance.dart';
import '../core/input_client/text_input_client_mixin.dart';
import '../core/selection/text_selection_controller.dart';
import '../core/selection/text_selection_delegate_mixin.dart';
import 'editor_render.dart';

class EditorLogic extends StatefulWidget {
  const EditorLogic({
    Key? key,
    required this.ownerId,
    required this.textHolder,
    required this.focusNode,
    required this.cursorStyle,
    required this.textCapitalization,
    required this.selectionColor,
    required this.selectionCtrls,
    required this.toolbarOptions,
    bool? scrollable,
    bool? readOnly,
    bool? showSelectionHandles,
    bool? showCursor,
    bool? expands = true,
    bool? autoFocus = true,
    Brightness? keyboardAppearance,
    bool? enableInteractiveSelection,
    this.customStyles,
    this.scrollPhysics,
    required this.scrollBottomInset,
    required this.padding,
    this.placeholder,
    this.onLaunchUrl,
    this.maxHeight,
    this.minHeight,
    this.floatingCursorDisabled = false,
    this.scribbleEnabled = false,
  })  : readOnly = readOnly ?? false,
        showSelectionHandles = showSelectionHandles ?? true,
        showCursor = showCursor ?? true,
        expands = expands ?? true,
        autoFocus = autoFocus ?? true,
        enableInteractiveSelection = enableInteractiveSelection ?? true,
        keyboardAppearance = keyboardAppearance ?? Brightness.light,
        super(key: key);

  final String ownerId;
  /// 文档控制器
  final TextHolder textHolder;

  /// 焦点管理器
  final FocusNode focusNode;

  final ToolbarOptions toolbarOptions;
  final bool readOnly;
  final bool showSelectionHandles;
  final bool showCursor;
  final CursorStyle cursorStyle;
  final TextCapitalization textCapitalization;

  final StyleTextData? customStyles;

  /// 是否展开文档内容最大化
  final bool expands;

  ///开启组件自动焦点
  final bool autoFocus;

  /// 选择区域颜色
  final Color selectionColor;
  final TextSelectionControls selectionCtrls;

  /// 键盘主题色
  final Brightness keyboardAppearance;

  /// 是否启用选择交互工具
  final bool enableInteractiveSelection;

  bool get selectionEnabled => enableInteractiveSelection;

  ///滚动物理效果
  final ScrollPhysics? scrollPhysics;

  /// 可滚动
  final double scrollBottomInset;
  final EdgeInsetsGeometry padding;
  final String? placeholder;
  final ValueChanged<String>? onLaunchUrl;
  final double? maxHeight;
  final double? minHeight;
  final bool floatingCursorDisabled;
  final bool scribbleEnabled;

  @override
  EditorLogicState createState() {
    return EditorLogicState();
  }
}

abstract class AbstractEditorLogic extends State<EditorLogic>
    implements
        TextInputClient,
        TextSelectionDelegate,
        TickerProviderStateMixin<EditorLogic> {
  AbstractEditorRenderBox get renderEditor;

  /// 得到光标控制器
  CursorController? get cursorController;

  /// 得到选择覆盖层
  TextSelectionController? get selectionController;

  ScrollController get scrollController;

  FloatingCursorUpdate get floatingCursorUpdate;

  /// 请求键盘
  void requestKeyboard();
}

class EditorLogicState extends AbstractEditorLogic
    with
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver,
        TickerProviderStateMixin,
        TextInputClientMixin,
        TextSelectionDelegateMixin {
  final GlobalKey _editorRenderKey = GlobalKey();

  // 键盘
  KeyboardVisibilityController? _keyboardVisibilityController;
  StreamSubscription<bool>? _keyboardVisibilitySubscription;
  bool _keyboardVisible = false;

  // 选区
  @override
  TextSelectionController? get selectionController => _selectionController;
  TextSelectionController? _selectionController;

  @override
  ScrollController get scrollController => _scrollController;
  late ScrollController _scrollController;

  @override
  FloatingCursorUpdate get floatingCursorUpdate => _floatingCursorUpdate;
  late FloatingCursorUpdate _floatingCursorUpdate;

  @override
  CursorController get cursorController => _cursorController;
  late CursorController _cursorController;

  // 焦点
  bool _didAutoFocus = false;
  bool get _hasFocus => widget.focusNode.hasFocus;

  late StyleTextData _styles;

  final ClipboardStatusNotifier _clipboardStatus = ClipboardStatusNotifier();
  final LayerLink _toolbarLayerLink = LayerLink(); //工具条位置
  final LayerLink _startHandleLayerLink = LayerLink(); //开始选取位置
  final LayerLink _endHandleLayerLink = LayerLink(); //结束选区位置

  TextDirection get _textDirection => Directionality.of(context);

  bool _showCaretOnScreenScheduled = false;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    super.build(context);

    final _node = widget.textHolder.localNode;
    //内容组件
    Widget child = CompositedTransformTarget(
      link: _toolbarLayerLink,
      child: EditorRender(
        key: _editorRenderKey,
        node: _node,
        selection: widget.textHolder.textSelection,
        hasFocus: _hasFocus,
        textDirection: _textDirection,
        startHandleLayerLink: _startHandleLayerLink,
        endHandleLayerLink: _endHandleLayerLink,
        onSelectionChanged: _handleSelectionChanged,
        onSelectionCompleted: _handleSelectionCompleted,
        padding: widget.padding,
        cursorController: cursorController,
        children: BuilderBlock(
                textDirection: _textDirection,
                enableInteractiveSelection: widget.enableInteractiveSelection,
                hasFocus: _hasFocus,
                selectionColor: widget.selectionColor,
                readOnly: widget.readOnly,
                rootNode: _node,
                styles: _styles,
                textHolder: widget.textHolder,
                devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                cursorCont: _cursorController,
                textSelection: widget.textHolder.textSelection)
            .buildChildren(),
      ),
    );

    child = AttributeStyles(
      data: _styles,
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: child,
      ),
    );

    child = Actions(
      actions: ActionInstance(editorBlock: this).actions,
      child: Focus(
        focusNode: widget.focusNode,
        child: KeyboardListener(child: child),
      ),
    );
    return child;
  }

  /// 处理选择改变
  /// 渲染层得到了选择信息， 传递给编辑器层，调用编辑器需要的逻辑
  /// 显示选择处理器
  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause cause) {
    //final oldSelection = widget.controller.selection;

    widget.textHolder.updateSelection(selection);

    _selectionController?.handlesVisible = _shouldShowSelectionHandles();

    if (!_keyboardVisible) {
      requestKeyboard();
    }

    // if (cause == SelectionChangedCause.drag) {
    //   if (oldSelection.baseOffset != selection.baseOffset) {
    //     bringIntoView(selection.base);
    //   } else if (oldSelection.extentOffset != selection.extentOffset) {
    //     bringIntoView(selection.extent);
    //   }
    // }
  }

  void _handleSelectionCompleted() {
    widget.textHolder.onSelectionCompleted?.call();
  }

  @override
  void initState() {
    super.initState();

    _clipboardStatus.addListener(_eventClipboardStatusChange);
    widget.textHolder.addListener(_eventTextEditingValueChange);

    //光标
    _cursorController = CursorController(
      show: ValueNotifier<bool>(widget.showCursor),
      style: widget.cursorStyle,
      tickerProvider: this,
    );

    _floatingCursorUpdate = FloatingCursorUpdate(editorLogicState: this);

    if (isKeyboardOS()) {
      _keyboardVisible = true;
    } else {
      // treat iOS Simulator like a keyboard OS
      isIOSSimulator().then((isIosSimulator) {
        if (isIosSimulator) {
          _keyboardVisible = true;
        } else {
          _keyboardVisibilityController = KeyboardVisibilityController();
          _keyboardVisible = _keyboardVisibilityController!.isVisible;
          _keyboardVisibilitySubscription =
              _keyboardVisibilityController?.onChange.listen((visible) {
            _keyboardVisible = visible;
            if (visible) {
              _changeTextEditingValue(!_hasFocus);
            }
          });
        }
      });
    }

    // Focus
    widget.focusNode.addListener(_eventFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parentStyles = AttributeStyles.of(context);
    final defaultStyles = StyleTextData.getInstance(context);
    _styles = (parentStyles != null)
        ? defaultStyles.merge(parentStyles)
        : defaultStyles;

    if (widget.customStyles != null) {
      _styles = _styles.merge(widget.customStyles!);
    }

    if (!_didAutoFocus && widget.autoFocus) {
      FocusScope.of(context).autofocus(widget.focusNode);
      _didAutoFocus = true;
    }
  }

  @override
  void didUpdateWidget(EditorLogic oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cursorController.setCursorValue(widget.cursorStyle, widget.showCursor);

    if (widget.textHolder != oldWidget.textHolder) {
      oldWidget.textHolder.removeListener(_eventTextEditingValueChange);
      widget.textHolder.addListener(_eventTextEditingValueChange);
      updateRemoteValueIfNeeded();
    }


    // mindmap不需要滚动
    // if (widget.scrollController != _scrollController) {
    //   _scrollController.removeListener(_updateSelectionOverlayForScroll);
    //   _scrollController = widget.scrollController;
    //   _scrollController.addListener(_updateSelectionOverlayForScroll);
    // }

    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_eventFocusChanged);
      widget.focusNode.addListener(_eventFocusChanged);
      updateKeepAlive();
    }

    if (widget.textHolder.textSelection != oldWidget.textHolder.textSelection) {
      selectionController?.update(textEditingValue);
    }
    selectionController?.handlesVisible = _shouldShowSelectionHandles();

    if (!shouldCreateInputConnection) {
      closeInputConnectionIfNeeded();
    } else {
      if (oldWidget.readOnly && _hasFocus) {
        openInputConnection();
      }
    }

    // in case customStyles changed in new widget
    if (widget.customStyles != null) {
      _styles = _styles.merge(widget.customStyles!);
    }
  }

  @override
  void dispose() {
    closeInputConnectionIfNeeded();
    _keyboardVisibilitySubscription?.cancel();
    assert(!hasInputConnection);
    _selectionController?.dispose();
    _selectionController = null;
    widget.textHolder.removeListener(_eventTextEditingValueChange);
    widget.focusNode.removeListener(_eventFocusChanged);
    _cursorController.dispose();
    _clipboardStatus
      ..removeListener(_eventClipboardStatusChange)
      ..dispose();
    super.dispose();
  }

  void _eventTextEditingValueChange() {
    _eventTextEditingValueChangeImpl(
        ignoreFocus: widget.textHolder.ignoreFocusOnTextChange);
  }

  void _eventFocusChanged() {
    AppLogger.docLog
        .i('handleFocusChanged ${widget.focusNode.debugLabel} hasFocus: ${widget.focusNode.hasFocus}');
    openOrCloseInputConnectionIfNeeded();
    _cursorController.startOrStopCursorTimerIfNeeded(
        _hasFocus, widget.textHolder.textSelection);
    _updateOrDisposeSelectionOverlayIfNeeded();
    if (_hasFocus) {
      WidgetsBinding.instance.addObserver(this);
      //     _showCaretOnScreen();
    } else {
      WidgetsBinding.instance.removeObserver(this);
    }
    updateKeepAlive();
  }

  /// 剪贴板
  void _eventClipboardStatusChange() {
    if (!mounted) return;
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
      // Trigger build and updateChildren
    });
  }

  /// 应该显示选择处理器
  bool _shouldShowSelectionHandles() {
    return widget.showSelectionHandles &&
        !widget.textHolder.textSelection.isCollapsed;
  }

  /// 文本监听
  void _eventTextEditingValueChangeImpl({bool ignoreFocus = false}) {
    // web
    if (kIsWeb) {
      _changeTextEditingValue(ignoreFocus);
      if (!ignoreFocus) {
        requestKeyboard();
      }
      return;
    }

    // 其他
    // 如果键盘已经准备好了，直接处理文本
    if (ignoreFocus || _keyboardVisible) {
      _changeTextEditingValue(ignoreFocus);
    } else {
      // 键盘没准备好，请求键盘
      requestKeyboard();
      if (mounted) {
        setState(() {
          // Use widget.controller.value in build()
          // Trigger build and updateChildren
        });
      }
    }
  }

  /// 文本可编辑对象被改变时
  void _changeTextEditingValue([bool ignoreCaret = false]) {
    // 更新输入法相关
    updateRemoteValueIfNeeded();
    if (ignoreCaret) {
      return;
    }

    // 显示光标
    _showCaretOnScreen();
    _cursorController.startOrStopCursorTimerIfNeeded(
        _hasFocus, widget.textHolder.textSelection);
    if (hasInputConnection) {
      _cursorController
        ..stopCursorTimer(resetCharTicks: false)
        ..startCursorTimer();
    }

    // 更新选区
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _updateOrDisposeSelectionOverlayIfNeeded();
    });
    if (mounted) {
      print('rebuild editor logic..............');
      setState(() {
        // Use widget.controller.value in build()
        // Trigger build and updateChildren
      });
    }
  }

  /// 更新或者销毁选择覆盖层
  void _updateOrDisposeSelectionOverlayIfNeeded() {
    if (_selectionController != null) {
      // 判断是否有焦点，也就是选区是否其作用
      if (_hasFocus) {
        // 直接更新选区内容
        _selectionController!.update(textEditingValue);
      } else {
        // 销毁选区
        _selectionController!.dispose();
        _selectionController = null;
      }
    } else if (_hasFocus) {
      // 创建选区
      _selectionController = TextSelectionController(
        textEditingValue,
        false,
        context,
        widget,
        _toolbarLayerLink,
        _startHandleLayerLink,
        _endHandleLayerLink,
        renderEditor,
        widget.selectionCtrls,
        this,
        DragStartBehavior.start,
        null,
        _clipboardStatus,
      );
      _selectionController!.handlesVisible = _shouldShowSelectionHandles();
      _selectionController!.showHandles();
    }
  }

  /// 显示插入符在屏幕上, 当输入值被改变了后调用，
  void _showCaretOnScreen() {
    if (!widget.showCursor || _showCaretOnScreenScheduled) {
      return;
    }

    _showCaretOnScreenScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // if (widget.scrollable) {
      //   _showCaretOnScreenScheduled = false;
      //
      //   // 获得编辑器核心渲染对象
      //   if (renderEditor == null) {
      //     return;
      //   }
      //
      //   final renderObject = renderEditor as RenderBox;
      //   // 得到这个渲染对象上面的[RenderAbstractViewport]
      //   final viewport = RenderAbstractViewport.of(renderObject);
      //   // 获得相对这个视口的偏移
      //   final editorOffset =
      //       renderObject.localToGlobal(const Offset(0, 0), ancestor: viewport);
      //   // 如果不存在滚动，则直接返回
      //   if (_scrollController.hasClients == false) {
      //     return;
      //   }
      //   final offsetInViewport = _scrollController.offset + editorOffset.dy;
      //
      //   final offset = renderEditor.getOffsetToRevealCursor(
      //     _scrollController.position.viewportDimension,
      //     _scrollController.offset,
      //     offsetInViewport,
      //   );
      //
      //   ///
      //   if (offset != null) {
      //     _scrollController.animateTo(
      //       offset,
      //       duration: const Duration(milliseconds: 100),
      //       curve: Curves.fastOutSlowIn,
      //     );
      //   }
      // }
    });
  }

  @override
  AbstractEditorRenderBox get renderEditor {
    return _editorRenderKey.currentContext!.findRenderObject()
        as AbstractEditorRenderBox;
  }

  /// 请求键盘或者焦点
  @override
  void requestKeyboard() {
    if (_hasFocus) {
      openInputConnection();
    } else {
      widget.focusNode.requestFocus();
    }
  }

  @override
  bool showToolbar() {
    if (kIsWeb) {
      return false;
    }
    if (_selectionController == null || _selectionController!.toolbar != null) {
      return false;
    }

    _selectionController!.update(textEditingValue);
    _selectionController!.showToolbar();
    return true;
  }

  @override
  bool get wantKeepAlive => widget.focusNode.hasFocus;
}

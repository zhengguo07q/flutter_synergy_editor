import 'package:flutter/cupertino.dart' hide Path;
import 'package:flutter/material.dart' hide Path;
import 'package:thinkhub_client/workbench/updater/dirty_updater.dart';
import 'package:slate/slate.dart';
import '../../updater/text_holder.dart';
import '../base/style/style_default.dart';
import '../core/cursor/cursor_style.dart';
import '../core/gesture/gesture_detector_builder.dart';
import 'editor_logic.dart';

///触摸按下
typedef OnTapDown = bool Function(
    TapDownDetails details, TextPosition Function(Offset offset));

///触摸弹起
typedef OnTapUp = bool Function(
    TapUpDetails details, TextPosition Function(Offset offset));

///手势滑动开始
typedef OnSingleLongTapStart = bool Function(
    LongPressStartDetails details, TextPosition Function(Offset offset));

///手势滑动
typedef OnSingleLongTapMoveUpdate = bool Function(
    LongPressMoveUpdateDetails details, TextPosition Function(Offset offset));

///手势滑动结束
typedef OnSingleLongTapEnd = bool Function(
    LongPressEndDetails details, TextPosition Function(Offset offset));

typedef TextSelectionChangedHandler = void Function(
    TextSelection selection, SelectionChangedCause cause);

typedef TextSelectionCompletedHandler = void Function();

/// 编辑器主组件类
///
/// 里面主要处理事件
class EditorBuilder extends StatefulWidget {
  const EditorBuilder({
    Key? key,
    required this.ownerId,
    required this.textHolder,
    required this.parentPath,
    required this.focusNode,
    required this.padding,
    required this.autoFocus,
    required this.readOnly,
    this.showCursor,
    this.placeholder,
    this.enableInteractiveSelection = true,
    this.scrollBottomInset = 0,
    this.customStyles,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardAppearance = Brightness.light,
    this.onTapDown,
    this.onTapUp,
    this.onSingleLongTapStart,
    this.onSingleLongTapMoveUpdate,
    this.onSingleLongTapEnd,
  }) : super(key: key);

  final String ownerId;

  /// 数据控制器
  final TextHolder textHolder;

  final Path parentPath;

  /// 是否自动焦点
  final bool autoFocus;

  /// 焦点
  final FocusNode focusNode;

  /// 滚动底部边距
  final double scrollBottomInset;

  /// 画布边框
  final EdgeInsetsGeometry padding;

  /// 是否显示光标
  final bool? showCursor;

  /// 是否只读
  final bool readOnly;

  /// 文档为"" 时默认插入的内容
  final String? placeholder;

  /// 是否启用选择交互工具
  final bool enableInteractiveSelection;

  /// 光标默认样式
  final StyleTextData? customStyles;

  /// 键盘类型
  final TextCapitalization textCapitalization;

  /// 键盘主题色
  final Brightness keyboardAppearance;

  ///触摸按下
  final OnTapDown? onTapDown;

  ///触摸弹起
  final OnTapUp? onTapUp;

  ///手势滑动开始
  final OnSingleLongTapStart? onSingleLongTapStart;

  ///手势滑动
  final OnSingleLongTapMoveUpdate? onSingleLongTapMoveUpdate;

  ///手势滑动结束
  final OnSingleLongTapEnd? onSingleLongTapEnd;

  @override
  EditorBuilderState createState() => EditorBuilderState();
}

class EditorBuilderState<T extends EditorBuilder> extends State<T>
    implements SelectionGestureDetectorBuilderDelegate {
  /// editorLogicKey
  late GlobalKey<EditorLogicState> _editorKey;

  @override
  GlobalKey<EditorLogicState> getEditableTextKey() => _editorKey;

  late SelectionGestureDetectorBuilder _selectionGestureDetectorBuilder;

  SelectionGestureDetectorBuilder get selectionGestureDetectorBuilder =>
      _selectionGestureDetectorBuilder;

  @override
  void initState() {
    super.initState();
    _editorKey = GlobalObjectKey(widget.parentPath);
    _selectionGestureDetectorBuilder =
        TextEditorSelectionGestureDetectorBuilder(this);
  }

  @override
  bool getForcePressEnabled() {
    return false;
  }

  @override
  bool getSelectionEnabled() {
    return widget.enableInteractiveSelection;
  }

  void requestKeyboard() {
    _editorKey.currentState!.requestKeyboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectionTheme = TextSelectionTheme.of(context);

    TextSelectionControls textSelectionControls; //选择控制器
    bool paintCursorAboveText; //在文本之上绘制光标？无效果
    bool cursorOpacityAnimates; //闪烁隐藏淡出效果
    Offset? cursorOffset;
    Color? cursorColor; //光标颜色
    Color selectionColor; //选择颜色
    Radius? cursorRadius;

    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        textSelectionControls = materialTextSelectionControls;
        paintCursorAboveText = false;
        cursorOpacityAnimates = false;
        cursorColor ??= selectionTheme.cursorColor ?? theme.colorScheme.primary;
        selectionColor = selectionTheme.selectionColor ??
            theme.colorScheme.primary.withOpacity(0.40);
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        final cupertinoTheme = CupertinoTheme.of(context);
        textSelectionControls = cupertinoTextSelectionControls;
        paintCursorAboveText = true;
        cursorOpacityAnimates = true;
        cursorColor ??=
            selectionTheme.cursorColor ?? cupertinoTheme.primaryColor;
        selectionColor = selectionTheme.selectionColor ??
            cupertinoTheme.primaryColor.withOpacity(0.40);
        cursorRadius ??= const Radius.circular(2);
        cursorOffset = Offset(
            iOSHorizontalOffset / MediaQuery.of(context).devicePixelRatio, 0);
        break;
      default:
        throw UnimplementedError();
    }

    return selectionGestureDetectorBuilder.build(
      HitTestBehavior.translucent,
      EditorLogic(
        key: getEditableTextKey(),
        ownerId: widget.ownerId,
        textHolder: widget.textHolder,
        focusNode: widget.focusNode,
        scrollBottomInset: widget.scrollBottomInset,
        padding: widget.padding,
        toolbarOptions: ToolbarOptions(
          copy: widget.enableInteractiveSelection,
          cut: widget.enableInteractiveSelection,
          paste: widget.enableInteractiveSelection,
          selectAll: widget.enableInteractiveSelection,
        ),
        cursorStyle: CursorStyle(
          color: cursorColor,
          backgroundColor: Colors.grey,
          width: 2,
          radius: cursorRadius,
          offset: cursorOffset,
          paintAboveText: paintCursorAboveText,
          opacityAnimates: cursorOpacityAnimates,
        ),
        textCapitalization: widget.textCapitalization,
        showSelectionHandles: true,
        selectionColor: selectionColor,
        selectionCtrls: textSelectionControls,
      ),
    );
  }
}

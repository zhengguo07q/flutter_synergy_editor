import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:slate/slate.dart';
import '../util/delta_util.dart';

import '../../main/editor_logic.dart';

/// 与键盘能力相关的混合
/// 键盘能力由以下几部分组成
///   1, [TextInputConfiguration] 做键盘的一些配置，比如什么种类键盘等
///   2, [TextInput] 底层键盘行为逻辑的回调的辅助实现
///   3, [TextInputClient] 提供底层逻辑回调的客户端(需用户实现)
///   4, [TextInputConnection] [attach]后返回，代表和底层的链接
///
/// 提供的主要能力有：
///   1, 打开键盘 [TextInput.attach] ,[TextInput.show]
///   2, 关闭键盘[TextInputConnection.close]
///   3, 选区内容变化时，更新输入法工具栏的远程值
///   4, 当输入时更新当前值
///
/// 当建立链接，并且用户触发键盘输入内容后，底层会调用[updateEditingValue] 来对值进行更新
/// 当文本被改变后，调用[updateRemoteValueIfNeeded]里的[TextInputConnection.setEditingState]更新输入法工具
mixin TextInputClientMixin on AbstractEditorLogic implements TextInputClient {
  final List<TextEditingValue> _sentRemoteValues = [];

  TextInputConnection? _textInputConnection;

  TextEditingValue? _lastKnownRemoteTextEditingValue;

  /// 是否创建一个与平台用于文本编辑的输入连接
  /// 只读输入字段不需要与平台连接，因为不需要文本编辑功能(例如虚拟键盘)。
  bool get shouldCreateInputConnection => kIsWeb || !widget.readOnly;

  bool get hasInputConnection =>
      _textInputConnection != null && _textInputConnection!.attached;

  /// 根据当前状态打开或关闭输入连接 [focusNode] 和 [value].
  void openOrCloseInputConnectionIfNeeded() {
    final hasFocus = widget.focusNode.hasFocus;
    if (hasFocus && widget.focusNode.consumeKeyboardToken()) {
      openInputConnection();
    } else if (!hasFocus) {
      closeInputConnectionIfNeeded();
    }
  }

  ///如果有需要，打开输入连接
  void openInputConnection() {
    if (!shouldCreateInputConnection) {
      return;
    }
    if (!hasInputConnection) {
      final TextEditingValue localValue = textEditingValue;

      _textInputConnection = TextInput.attach(this, textInputConfiguration);
      // scribbleController.updateSizeAndTransform();
      // scribbleController.updateComposingRectIfNeeded();
      // scribbleController.updateCaretRectIfNeeded();
      _textInputConnection!
        ..setEditingState(localValue)
        ..show();
      _lastKnownRemoteTextEditingValue = localValue;

      _lastKnownRemoteTextEditingValue = localValue;
      _updateSizeAndTransform();
      _textInputConnection!.setEditingState(_lastKnownRemoteTextEditingValue!);
      //_sentRemoteValues.add(_lastKnownRemoteTextEditingValue);
    } else {
      _textInputConnection!.show();
    }
  }

  TextInputConfiguration get textInputConfiguration {
    const autofillConfiguration = AutofillConfiguration.disabled;
    return TextInputConfiguration(
      readOnly: widget.readOnly,
      inputType: TextInputType.multiline,
      inputAction: TextInputAction.newline,
      enableSuggestions: !widget.readOnly,
      keyboardAppearance: widget.keyboardAppearance,
      textCapitalization: widget.textCapitalization,
      autofillConfiguration: autofillConfiguration,
    );
  }

  void _updateSizeAndTransform() {
    if (hasInputConnection) {
      // Asking for renderEditor.size here can cause errors if layout hasn't
      // occurred yet. So we schedule a post frame callback instead.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final size = renderEditor.size;
        final transform = renderEditor.getTransformTo(null);
        _textInputConnection?.setEditableSizeAndTransform(size, transform);
      });
    }
  }

  /// 关闭当前打开的输入连接。否则什么也不做。
  void closeInputConnectionIfNeeded() {
    if (hasInputConnection) {
      _textInputConnection!.close();
      _textInputConnection = null;
      _lastKnownRemoteTextEditingValue = null;
      _sentRemoteValues.clear();
    }
  }

  /// 基于当前 [node] 和 [textSelection]更新远程值到输入法栏
  ///
  /// 如果远程值是最新的或者相同的，这个方法不会发送更新到本机端，
  void updateRemoteValueIfNeeded() {
    if (!hasInputConnection) {
      return;
    }

    // 因为我们没有跟踪所提供的value中的合成范围
    // 通过控制器，我们需要在比较之前手动添加它最后一个已知的远程值。
    // 防止过多的远程更新是很重要的，因为它可能会导致竞态条件。
    final actualValue = textEditingValue.copyWith(
      composing: _lastKnownRemoteTextEditingValue!.composing,
    );

    if (actualValue == _lastKnownRemoteTextEditingValue) {
      return;
    }

    final shouldRemember =
        textEditingValue.text != _lastKnownRemoteTextEditingValue!.text;
    _lastKnownRemoteTextEditingValue = actualValue;
    _textInputConnection!.setEditingState(
      // Set composing to (-1, -1), otherwise an exception will be thrown if
      // the values are different.
      actualValue.copyWith(composing: const TextRange(start: -1, end: -1)),
    );
    if (shouldRemember) {
      // 只在文本发生变化时跟踪(选择的变化无关紧要)
      _sentRemoteValues.add(actualValue);
    }
  }

  @override
  TextEditingValue? get currentTextEditingValue =>
      _lastKnownRemoteTextEditingValue;

  /// 底层调用，触发逻辑值更新
  ///
  /// 这里的输入很比较复杂，比如说输入中文，sd，则会触发6次调用。
  ///   输入s的时候，触发两次。
  ///     第一次没用改变输入，composing的文本范围相同TextRange(start: 31, end: 31)
  ///     第二次改变输入，composing的文本范围+1TextRange(start: 31, end: 32)
  ///   输入d, 触发一次
  ///     改变输入，加入'd, composing的文本范围+2TextRange(start: 31, end: 34)
  ///   输入空格，填入值触发3次
  ///     改变输入，s'd 去掉，改为 "深度" composing的文本范围+2TextRange(start: 31, end: 33) 范围值变为2
  ///     composing: TextRange(start: 33, end: 33))
  ///     composing: TextRange(start: -1, end: -1))
  ///
  /// 当标记文本范围为-1,-1时候，则说明已经输入完成
  @override
  void updateEditingValue(TextEditingValue value) {
    if (!shouldCreateInputConnection) {
      return;
    }

    if (_sentRemoteValues.contains(value)) {
      // 在发送的文本输入插件中有一个竞争条件，对本机端的更新经常会导致错误的行为。
      // [TextInputConnection.setEditingValue]是对本机端的异步调用。
      // 对于每一个这样的调用，本地端总是会发送一个触发的更新，这个方法(updateEditingValue)具有我们发送给它的相同的值。
      // 如果太快多次调用setEditingValue，我们只跟踪最后发送的值，那么我们没有办法过滤掉从本地端自动回调。
      // 因此在这里我们必须跟踪我们发送给本机的所有值，当我们看到相同的值出现在这里时，我们跳过它。
      // 这不是一个好的解决方案，但它可能是唯一可用的选择。
      _sentRemoteValues.remove(value);
      return;
    }

    // 上一次值相同，不处理
    if (_lastKnownRemoteTextEditingValue == value) {
      return;
    }

    // 屏蔽掉[TextRange]影响
    if (_lastKnownRemoteTextEditingValue!.text == value.text &&
        _lastKnownRemoteTextEditingValue!.selection == value.selection) {
      _lastKnownRemoteTextEditingValue = value;
      return;
    }

    // 之前的值
    final effectiveLastKnownValue = _lastKnownRemoteTextEditingValue!;
    // 当前的值
    _lastKnownRemoteTextEditingValue = value;
    final oldText = effectiveLastKnownValue.text;
    final text = value.text;
    final cursorPosition = value.selection.extentOffset;
    // 得到当前的值和上一次提交的值的变更
    final diff = DeltaUtil.getDiff(oldText, text, cursorPosition);
    if (diff.inserted == '' && diff.deleted == '') {
      return;
    }
    // 提交变更, 一般情况下是插入， 但是当插入和删除都不为null时，说明这个时候一般是取代之前的字符，就是退格删除
    if (diff.deleted.isNotEmpty && diff.inserted.isNotEmpty) {
      TextTransforms.delete(widget.textHolder.document,
          distance: diff.deleted.length, reverse: true);
    }
    TextTransforms.insertText(widget.textHolder.document, diff.inserted);
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    floatingCursorUpdate.updateFloatingCursor(point);
  }

  /// 关闭链接
  @override
  void connectionClosed() {
    if (!hasInputConnection) {
      return;
    }
    _textInputConnection!.connectionClosedReceived();
    _textInputConnection = null;
    _lastKnownRemoteTextEditingValue = null;
    _sentRemoteValues.clear();
  }

  /// 不需要自动填充
  @override
  AutofillScope? get currentAutofillScope => null;

  /// IME输入动作导致的操作
  @override
  void performAction(TextInputAction action) {
    // no-op
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {
    // no-op
  }
  @override
  void showAutocorrectionPromptRect(int start, int end) {
    // no-op
  }

  @override
  void insertTextPlaceholder(Size size) {}

  @override
  void removeTextPlaceholder() {}
}

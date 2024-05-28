import 'package:common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/initialize.dart';
import 'package:thinkhub_client/workbench/updater/dirty_updater.dart';
import 'package:thinkhub_client/workbench/updater/document_controller.dart';

/// 持有可编辑的节点信息
///
/// 这个对象持有可编辑的节点
/// 获取可编辑的节点， 更新选择
/// 一个编辑器持有一个这个对象， 创建时注册
/// 每次更新这个节点时，则会导致重刷内容
class TextHolder extends ChangeNotifier {
  TextHolder(this.parentPath, this.localNode);

  final Path parentPath;
  final Node localNode;

  bool ignoreFocusOnTextChange = false;

  late TextSelection _textSelection;
  TextSelection get textSelection => _textSelection;

  late TextEditingValue _textEditingValue;
  TextEditingValue get textEditingValue => _textEditingValue;

  void Function()? onSelectionCompleted;

  late final DirtyUpdater dirtyUpdater;
  late final Document document;


  void initialize(DocumentController documentController) {
    dirtyUpdater = documentController.dirtyUpdater;
    document = documentController.document;
  }

  /// 第一次的时候和每次被调用时更新
  updateCache() {
    if (document.selection == null ||
        parentPath.isAncestor(document.selection!.common()) == false) {
      _textSelection = const TextSelection.collapsed(offset: 0);
    } else {
      final currentLocalSelection =
          SelectionUtil.globalToLocal(parentPath, document.selection!);
      _textSelection = SelectionUtil.transformLocalRangeSelection(
          localNode, currentLocalSelection);
    }
    //AppLogger.slateLog.i('updateCache ${document.selection} local $_textSelection');
    _textEditingValue =
        TextEditingValue(text: localNode.string(), selection: _textSelection);
  }

  /// 作为子节点，提交选择到文档上面去
  void updateSelection(TextSelection localTextSelection) {
    dirtyUpdater.updateSelection(
      parentPath,
      localNode,
      localTextSelection,
      _clickPosition,
    );
  }

  /// 点击在本地的位置
  late Point _clickPosition;

  setClickPoint(Node clickNode, int clickOffset) {
    final localPath = clickNode.getPath(parentNode: localNode);
    _clickPosition = Point.of(localPath, clickOffset);
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:slate/slate.dart';
import 'package:common/common.dart';
import 'package:thinkhub_client/workbench/updater/text_holder.dart';

import '../../initialize.dart';
import 'document_controller.dart';

/// 脏节点以ID作为唯一性
/// 整个导图节点被删除或者插入的时候， 需要对整个文档进行更新
/// 导图节点内部更新时，
class DirtyUpdater extends ChangeNotifier {
  DirtyUpdater(this.documentController) {
    document = documentController.document;
  }
  final DocumentController documentController;
  late final Document document;

  final Map<String, Attribute> toolbarButtonToggle = {};

  // 里面暂存值通知器， 与外界进行关联的时候尽量避免使用节点进行关联
  Map<String, List<TextHolder>> textHoldersMap = {};

  void addTextHolder(String ownerId, TextHolder textHolder) {
    final textHolders =
        textHoldersMap.putIfAbsent(ownerId, () => <TextHolder>[]);
    textHolders.add(textHolder);
    textHolder.initialize(documentController);
    textHolder.updateCache();
  }

  void removeTextHolder(String ownerId, TextHolder textHolder) {
    final textHolders =
        textHoldersMap.putIfAbsent(ownerId, () => <TextHolder>[]);
    textHolders.remove(textHolder);
  }

  void updateSelection(Path parentPath, Node localNode,
      TextSelection localTextSelection, Point localCursorPoint) {
    final document = documentControllerInstance.document;
    final localRange = SelectionUtil.transformLocalTextSelection(
        localNode, localTextSelection, localCursorPoint);
    final newSelection = SelectionUtil.localToGlobal(parentPath, localRange);

    AppLogger.selectionLog.i('updateSelection $newSelection');
    SelectionTransforms.select(document, newSelection);
  }

  notifyDirtyUpdate({bool force = false}) {
    final document = documentControllerInstance.document;
    bool isGlobalUpdate = force;
    // 是否需要全局更新
    for (var dirtyNode in document.frameDirtyNodes) {
      if (dirtyNode.dirtyType == DirtyType.insert ||
          dirtyNode.dirtyType == DirtyType.delete) {
        isGlobalUpdate = true;
        break;
      }
    }
    for (var dirtyNode in document.frameDirtyNodes) {
      if (dirtyNode.dirtyType == DirtyType.update ||
          dirtyNode.dirtyType == DirtyType.select) {
        final kid = dirtyNode.node.kId;
        if (textHoldersMap.containsKey(kid)) {
          final textHolders = textHoldersMap[kid]!;
          for (var textHolder in textHolders) {
            textHolder.updateCache();
            textHolder.notifyListeners();
          }
        }
      }
    }
    if (isGlobalUpdate) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    textHoldersMap.forEach((id, textHolders) {
      for (var textHolder in textHolders) {
        textHolder.dispose();
      }
      textHolders.clear();
    });
    textHoldersMap.clear();
    super.dispose();
  }
}

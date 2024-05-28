import 'dart:convert';

import 'package:common/common.dart';
import 'package:crdt/crdt.dart';
import 'package:flutter/material.dart' hide LayoutBuilder;
import 'package:protocol/protocol.dart';
import 'package:slate/slate.dart';
import 'package:thinkhub_client/core/utils/url_util.dart';
import 'package:thinkhub_client/features/storage/hive_document.dart';

import '../../../initialize.dart';
import '../layout/layout_builder.dart';
import 'dirty_updater.dart';

///文档控制器类
class DocumentController extends ChangeNotifier {
  DocumentController() {
    print('create DocumentController $hashCode');
  }

  /// 当前的文档
  late DocumentRoot document = DocumentRoot();

  late final DirtyUpdater dirtyUpdater = DirtyUpdater(this);

  /// 布局信息

  bool ignoreFocusOnTextChange = false;

  Future<void> init() async {
    loadDocument('[]');
    // await loadDocumentByOpenId();
    onLoadDocumentComplete();
  }

  void loadDocument(String jsonString) {
    final json = jsonDecode(jsonString) as List<dynamic>;
    document = DocumentRoot.fromJson(json);
  }

  void loadDocumentFromXml(String xmlString) {
    document = DocumentRoot.fromXml(xmlString);
  }

  Future<void> loadDocumentByOpenId({String? openId, int? depth}) async {
    final hiveDocument = sl.get<HiveDocument>();
    await hiveDocument.loadNodeByOpenId(
        document: document, openId: openId, depth: depth);
    startYJS('self');
  }

  void onLoadDocumentComplete() {
    document.callback = documentCallback;
  }

  WebrtcProvider? provider;

  /// 开启协同
  ///
  /// 第一步，建立与远程的连接
  void startYJS(String roomName, {bool create = true}) {
    AppLogger.docLog.i('重启协同');
    closeYjs();
    final doc = Doc();
    final sharedDoc = doc.getArray<SyncNode>('content');

    // 这个是创建，则需要把当前的内容提前注入yjs里面
    if (create) {
      ObjectConvert.toSharedDoc(sharedDoc, document.children);
      clear();
    }

    provider =
        WebrtcProvider(roomName, doc, signaling: ['ws://localhost:4444']);
    document.initYjs(sharedDoc, getRandomString());
    document.initCursor(provider!.awareness);
    // 每次需要同步时，则调用这个
    provider!.on('synced', (List<dynamic> args) {
      final isSynced = args[0] as bool;
      if (isSynced && sharedDoc.isEmpty) {
        ObjectConvert.toSharedDoc(sharedDoc, document.children);
      }
    });
    provider!.connect();
  }

  void closeYjs() {
    if (provider != null) {
      provider!.disconnect();
      provider!.destroy();
      provider = null;
    }
  }

  /// 设置布局
  void setLayoutBuilder(LayoutType layoutType) {
    layoutBuilderInstance.setLayoutType(layoutType);
  }

  /// 第一次时，不应该需要全局更新和保存
  void documentCallback({bool init = false}) {
    if (init == false) {
      hiveDocumentInstance.addStore(document.frameDirtyNodes);
      dirtyUpdater.notifyDirtyUpdate();
      document.frameDirtyNodes.clear();
    }
  }

  /// 清理掉数据
  void clear() {
    document.children.clear();
    document.selection = null;
  }

  @override
  void dispose() {
    dirtyUpdater.dispose();
    super.dispose();
  }
}

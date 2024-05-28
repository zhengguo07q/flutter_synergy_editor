import 'package:slate/slate.dart';
import 'package:common/common.dart';
import 'package:thinkhub_client/features/storage/util/id_util.dart';

class MindMapSupport {
  /// 插入兄弟节点下面
  ///
  /// 默认插入位置为文档尾部， 如果是插入到了第一个兄弟节点后面， 则是不被允许直接插入
  /// [bodyStr] 插入数据
  /// [siblingNode] 插入在这个兄弟节点下面
  static void insertNextSibling(Document document, String bodyStr,
      {Node? selectedNode}) {
    final newNode = NodeUtil.refInstance(bodyStr);
    Path? nextPath;
    if (selectedNode == null) {
      // 第一个节点只能插入在后面而不能插入到下面
      if (TopNodeUtil.isSelectedFirstNode(document)) {
        return;
      }
      selectedNode ??= TopNodeUtil.getSelectedTopNode(document);
    }

    // 深度同级
    buildAndCacheNodeInfo(newNode, selectedNode.nodeCache.depth!);

    final parentNode = SlateCache.getCacheNode(selectedNode.kParentId);
    buildRelation(document, newNode, parentNode!, insertInLast: false);

    // 位置放在选择节点的后面
    nextPath = TopNodeUtil.getSelectedTopPath(document).next();
    NodeTransforms.insertNodes(document, [newNode], atl: nextPath, select: true);
  }

  /// 插入子节点
  ///
  /// 一般是插入到孩子的最后一个
  /// [bodyStr] 插入数据
  /// [parentNode] 插入在这个父亲节点后面
  static void insertChild(Document document, String bodyStr,
      {Node? selectedNode}) {
    final newNode = NodeUtil.refInstance(bodyStr);
    Path? nextPath;
    Node? parentNode = selectedNode;
    if (selectedNode == null) {
      // 更新参照节点
      selectedNode ??= TopNodeUtil.getSelectedTopNode(document);
      parentNode = selectedNode;
      // 父子节点 id缓存 选择的节点当作父节点, 插入在所有节点后面
    }

    // 构建节点并且深度+1
    buildAndCacheNodeInfo(newNode, selectedNode.nodeCache.depth! + 1);
    final nextIndex = buildRelation(document, newNode, parentNode!, insertInLast: true);
    // 定位节点所在的前一个节点
    Node prevNode ;
    if(nextIndex == 0){
      prevNode = parentNode;
    }else{
      final prevId = parentNode.kChildrenIds![nextIndex -1];
      prevNode =  SlateCache.getCacheNode(prevId)!;
    }

    // 父节点的孩子的最后一位
    nextPath = TopNodeUtil.getPath(document, prevNode).next();
    // 位置放在子节点的最后节点后面
    NodeTransforms.insertNodes(document, [newNode], atl: nextPath, select: true);
  }

  /// 为新创建的节点添加深度信息和缓存这个节点
  static void buildAndCacheNodeInfo(Node newNode, int depth) {
    final newId = IDUtil.generateId();
    newNode
      ..kId = newId
      ..nodeCache.depth = depth;
    SlateCache.addCacheNode(newId, newNode);
  }

  /// 父子节点 id缓存
  ///
  /// [insertInLast] 是否强制插入到最后面，这代表[parentNode]不是选择节点
  /// 返回插入的位置
  static int buildRelation(Document document, Node newNode, Node parentNode,
      {bool insertInLast = false}) {
    newNode.kParentId = parentNode.kId;
    List<String> childrenIds = List<String>.of(parentNode.kChildrenIds ?? []) ;
    // 添加到兄弟后面
    List<String> newChildrenIds;
    int nextIndex;
    if (insertInLast) {
      // 插入到孩子的后面则是直接追加，而不用加到选择节点后面
      nextIndex = childrenIds.length;
      newChildrenIds = childrenIds..insert(childrenIds.length, newNode.kId);
    } else {
      // 这里是插入到选择节点的兄弟节点
      final index = TopNodeUtil.getSelectedIndexInParent(document);
      nextIndex = index + 1;
      newChildrenIds = childrenIds..insert(nextIndex, newNode.kId);
    }

    final newChildrenIdsAttr = ChildrenIdsAttribute(newChildrenIds);
    NodeTransforms.setNodes(
        document, {AttributeRegister.childrenIds.key: newChildrenIdsAttr},
        atl: TopNodeUtil.getPath(document, parentNode));
    AppLogger.slateLog
        .i('build relation kId ${newNode.kId} kParentId ${newNode.kParentId}');
    return nextIndex;
  }
}

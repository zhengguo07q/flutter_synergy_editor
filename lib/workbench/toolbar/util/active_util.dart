import 'package:slate/slate.dart';

class ActiveUtil {
  /// 快级属性判断
  static bool isBlockActive(Document document, String format,
      {blockType = 'type'}) {
    final selection = document.selection;
    if (selection == null) return false;

    final nodeList = LocationPathEntry.nodes(
      document,
      at: LocationRange.unhangRange(document, selection),
      match: ({Node? node, Path? path}) =>
          !EditorCondition.isEditor(node) &&
          KElement.isElement(node!) &&
          node.type == format,
    );
    return nodeList.isNotEmpty ? true : false;
  }

  /// 行内属性判断
  static bool isMarkActive(Document document, String format, {bool isCollapsed=true}) {
    final marks = EditorMark.getMarks(document, isCollapsed: isCollapsed);
    return marks.containsKey(format);
  }
}

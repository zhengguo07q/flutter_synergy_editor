import 'package:slate/slate.dart';
import 'package:thinkhub_client/workbench/layout/layout_builder.dart';

class EdgeInfo {
  EdgeInfo(this.sourceId, this.targetId);

  String sourceId;
  String targetId;

  getSize(){

  }

  getPosition(){

  }
}

class NodeInfo {
  late Node node;
  late String id;

  // 位置
  double x = 0;
  double y = 0;
  double actualX = 0;
  double actualY = 0;
  double centX = 0;
  double centY = 0;

  // 大小
  double hGap = 0;
  double vGap = 0;
  double height = 0;
  double width = 0;
  double actualHeight = 0;
  double actualWidth = 0;

  // 深度
  int depth = 0;

  //布局方向
  LayoutOrientation orientation = LayoutOrientation.right;

  bool isRoot() {
    if (depth == 1) {
      return true;
    }
    return false;
  }

  /// 新的内部宽
  void update(double width, double height) {
    actualWidth = width;
    actualHeight = height;
    this.width = actualWidth + 2 * hGap;
    this.height = actualHeight + 2 * vGap;
    centX = x + this.width / 2;
    centY = y + this.height / 2;
  }
}

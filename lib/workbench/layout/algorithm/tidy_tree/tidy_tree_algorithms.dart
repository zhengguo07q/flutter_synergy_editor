import 'package:thinkhub_client/workbench/layout/algorithm/tidy_tree/algorithm_util.dart';
import 'package:thinkhub_client/workbench/layout/algorithm/tidy_tree/tidy_tree_data.dart';
import 'package:thinkhub_client/workbench/layout/layout_builder.dart';

class IYLInfo {
  IYLInfo(this.low, this.index, this.nxt);

  double low;
  int index;
  IYLInfo? nxt;
}

/// NonLayeredTidyTreeAlgorithms
///
/// 无分层发育树算法
class TidyTreeAlgorithms extends Algorithm {
  @override
  NodeData run(NodeData root, bool isHorizontal) {
    AlgorithmUtil.layer(root, isHorizontal);
    final wt = TidyTreeData.fromNode(root, isHorizontal);
    firstWalk(wt);
    secondWalk(wt, 0);
    AlgorithmUtil.convertBack(wt, root, isHorizontal);
    AlgorithmUtil.normalize(root, isHorizontal);
    return root;
  }

  /// 遍历初始化计算和设置整个节点树的extremes信息
  void firstWalk(TidyTreeData t) {
    // 是叶子节点
    if (t.cs == 0) {
      setExtremes(t);
      return;
    }
    firstWalk(t.c[0]);
    var ih = updateIYL(bottom(t.c[0].el!), 0, null);
    // 对当前节点除开第一个外所有子节点进行遍历walk
    for (var i = 1; i < t.cs; ++i) {
      firstWalk(t.c[i]);
      final min = bottom(t.c[i].er!);
      separate(t, i, ih);
      ih = updateIYL(min, i, ih);
    }
    positionRoot(t);
    setExtremes(t);
  }

  /// 设置边界数据
  void setExtremes(TidyTreeData t) {
    if (t.cs == 0) {
      // 没用子节点，边界数据为它自身，mse为0
      t.el = t
        ..er = t
        ..msel = 0
        ..mser = 0;
    } else {
      // 存在子节点，则边界数据为它子节点的第一个和最后一个
      t
        ..el = t.c[0].el
        ..msel = t.c[0].msel
        ..er = t.c[t.cs - 1].er
        ..mser = t.c[t.cs - 1].mser;
    }
  }

  void separate(TidyTreeData t, int i, IYLInfo ih) {
    TidyTreeData? sr = t.c[i - 1];
    var mssr = sr.mod;
    TidyTreeData? cl = t.c[i];
    var mscl = cl.mod;
    while (sr != null && cl != null) {
      if (bottom(sr) > ih.low) {
        ih = ih.nxt!;
      }
      final dist = mssr + sr.prelim + sr.w - (mscl + cl.prelim);
      if (dist > 0) {
        mscl += dist;
        moveSubtree(t, i, ih.index, dist);
      }
      final sy = bottom(sr);
      final cy = bottom(cl);
      if (sy <= cy) {
        sr = nextRightContour(sr);
        if (sr != null) mssr += sr.mod;
      }
      if (sy >= cy) {
        cl = nextLeftContour(cl);
        if (cl != null) mscl += cl.mod;
      }
    }
    if (sr == null && cl != null) {
      setLeftThread(t, i, cl, mscl);
    } else if (sr != null && cl == null) {
      setRightThread(t, i, sr, mssr);
    }
  }

  void moveSubtree(TidyTreeData t, int i, int si, double dist) {
    t.c[i].mod += dist;
    t.c[i].msel += dist;
    t.c[i].mser += dist;
    distributeExtra(t, i, si, dist);
  }

  TidyTreeData? nextLeftContour(TidyTreeData t) {
    return t.cs == 0 ? t.tl : t.c[0];
  }

  TidyTreeData? nextRightContour(TidyTreeData t) {
    return t.cs == 0 ? t.tr : t.c[t.cs - 1];
  }

  /// 计算这个节点的bottom位置
  double bottom(TidyTreeData t) {
    return t.y + t.h;
  }

  void setLeftThread(TidyTreeData t, int i, TidyTreeData cl, double modsumcl) {
    final li = t.c[0].el!..tl = cl;
    final diff = modsumcl - cl.mod - t.c[0].msel;
    li
      ..mod += diff
      ..prelim -= diff;
    t.c[0].el = t.c[i].el;
    t.c[0].msel = t.c[i].msel;
  }

  void setRightThread(TidyTreeData t, int i, TidyTreeData sr, double modsumsr) {
    final ri = t.c[i].er!..tr = sr;
    final diff = modsumsr - sr.mod - t.c[i].mser;
    ri
      ..mod += diff
      ..prelim -= diff;
    t.c[i].er = t.c[i - 1].er;
    t.c[i].mser = t.c[i - 1].mser;
  }

  void positionRoot(TidyTreeData t) {
    t.prelim = (t.c[0].prelim +
                t.c[0].mod +
                t.c[t.cs - 1].mod +
                t.c[t.cs - 1].prelim +
                t.c[t.cs - 1].w) /
            2 -
        t.w / 2;
  }

  void secondWalk(TidyTreeData t, double modsum) {
    modsum += t.mod;
    t.x = t.prelim + modsum;
    addChildSpacing(t);
    for (var i = 0; i < t.cs; i++) {
      secondWalk(t.c[i], modsum);
    }
  }

  void distributeExtra(TidyTreeData t, int i, int si, double dist) {
    if (si != i - 1) {
      final nr = i - si;
      t.c[si + 1].shift += dist / nr;
      t.c[i].shift -= dist / nr;
      t.c[i].change -= dist - dist / nr;
    }
  }

  void addChildSpacing(TidyTreeData t) {
    var d = 0.0;
    var modsumdelta = 0.0;
    for (var i = 0; i < t.cs; i++) {
      d += t.c[i].shift;
      modsumdelta += d + t.c[i].change;
      t.c[i].mod += modsumdelta;
    }
  }

  IYLInfo updateIYL(double low, int index, IYLInfo? ih) {
    while (ih != null && low >= ih.low) {
      ih = ih.nxt;
    }
    return IYLInfo(low, index, ih);
  }
}

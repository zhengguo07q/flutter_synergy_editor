import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    hide InteractiveViewer, TransformationController;
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thinkhub_client/features/theme/state/config.dart';
import 'package:thinkhub_client/features/workbench/notifier/mind_map_navigator.dart';

final _interactiveViewerGlobalKey = GlobalKey();

/// 可以交互滚动的视图
class InteractiveViewerExtend extends ConsumerStatefulWidget {
  const InteractiveViewerExtend({
    Key? key,
    required this.keyList,
    required this.child,
    required this.transformationController,
  }) : super(key: key);

  final List<GlobalKey> keyList;
  final Widget child;
  final TransformationController transformationController;
  @override
  InteractiveViewerExtendState createState() => InteractiveViewerExtendState();
}

class InteractiveViewerExtendState
    extends ConsumerState<InteractiveViewerExtend>
    with SingleTickerProviderStateMixin {
  late Animation<Matrix4> animation;
  late AnimationController animationController;

  late VoidCallback animationListener;
  late Size canvasSize;
  int? lastIndex;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    //更新视图位置
    animationListener = () {
      setState(() {
        // 平移时，朝手指移动相反的方向移动画布。视口不动，画布动
        widget.transformationController.value =
            Matrix4.inverted(animation.value);
      });
    };

    // 主渲染管道已刷新后，缓存画布尺寸，初始化画布视口导航
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final nodeRenderBox =
          getRenderBoxByGlobalKey(_interactiveViewerGlobalKey);
      canvasSize = nodeRenderBox.size;
      ref.watch(mindMapNavigatorProvider.notifier).addListener((state) {
        navigateViewerToNode(state);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 添加一个动画控制器， 在300毫秒内 颜色变化
    return AnimatedContainer(
      color: ref.watch(backgroundColorPod) ?? theme.scaffoldBackgroundColor,
      duration: const Duration(milliseconds: 300),
      // 滑动视图
      child: InteractiveViewer(
        key: _interactiveViewerGlobalKey,
        boundaryMargin: const EdgeInsets.all(1000),
        constrained: false,
        transformationController: widget.transformationController,
        child: widget.child,
      ),
    );
  }

  // 导航至指定节点
  void navigateViewerToNode(int to, [int? from]) {
    if (widget.keyList.isEmpty) {
      return;
    }
    // 获取开始的点
    final toNodeKey = widget.keyList.elementAt(to);
    Matrix4 begin;

    // 还原最后的节点
    from ??= lastIndex;

    if (from == null) {
      // 初始化画布视口导航，默认位置为画布中心
      final startPoint = Point(canvasSize.width / 2, canvasSize.height / 2);
      begin = Matrix4.identity()..translate(startPoint.x, startPoint.y);
    } else {
      // TODO Add Feature 2021年9月30日 利用 from 实现节点至节点的导航 用于教程等功能
      begin = Matrix4.inverted(widget.transformationController.value);
    }

    // 节点位置
    final endPoint = calculateCenterPoint(toNodeKey);
    final endMatrix = Matrix4.identity()..translate(endPoint.x, endPoint.y);

    print(begin);
    widget.transformationController.value = begin;
    print(begin);
    print(widget.transformationController.value);

    // 混入缓动曲线
    final curvedAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn,
    );

    // 定义基础补间动画
    animation = Matrix4Tween(
      begin: begin,
      end: endMatrix,
    ).animate(curvedAnimation)
      ..addListener(animationListener)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animation.removeListener(animationListener);
        }
      });

    // 驱动动画
    animationController
      ..reset()
      ..forward();

    // 缓存最后的节点
    lastIndex = to;
  }

  // 计算节点局部中心点
  Point<double> calculateCenterPoint(GlobalKey nodeKey) {
    final nodeRenderBox = getRenderBoxByGlobalKey(nodeKey);
    // 相对于父亲的偏移和节点自身的大小
    final offset = getOffsetInParent(nodeRenderBox);
    final size = nodeRenderBox.size;

    final middleX = canvasSize.width / 2;
    final middleY = canvasSize.height / 2;

    return Point<double>(
      offset!.dx - middleX + size.width / 2, // 相对于Node，再次调整中心点
      offset.dy - middleY + size.height / 2,
    );
  }

  /// 得到节点的渲染BOX
  RenderBox getRenderBoxByGlobalKey(GlobalKey globalKey) {
    return globalKey.currentContext!.findRenderObject() as RenderBox;
  }

  /// 获得节点局部坐标
  Rect? getRect(RenderBox nodeRenderBox) {
    final translation = nodeRenderBox.getTransformTo(null).getTranslation();
    final size = nodeRenderBox.semanticBounds.size;

    return translation != null
        ? Rect.fromLTWH(translation.x, translation.y, size.width, size.height)
        : null;
  }

  /// 获得节点在父容器的局部坐标系
  Offset? getOffsetInParent(RenderBox nodeRenderBox) {
    final childOffset = nodeRenderBox.localToGlobal(Offset.zero);
    //
    // // 转换：将[RenderBox] 从全局坐标系 转换为 父容器的 局部坐标系
    // final parent = GlobalKeyDef.layerKeyEditor.currentContext!
    //     .findRenderObject()! as RenderBox;
    //
    // return parent.globalToLocal(childOffset);
  }

  @override
  void dispose() {
    widget.transformationController.dispose();
    animationController.dispose();
    super.dispose();
  }
}

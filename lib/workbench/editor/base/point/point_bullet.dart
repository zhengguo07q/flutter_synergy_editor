import 'package:flutter/material.dart';

/// 代表一个点
class PointBullet extends StatelessWidget {
  const PointBullet({
    required this.style,
    required this.width,
    Key? key,
  }) : super(key: key);

  final TextStyle style;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.topEnd,
      width: width,
      padding: const EdgeInsetsDirectional.only(end: 13),
      child: Text('•', style: style),
    );
  }
}

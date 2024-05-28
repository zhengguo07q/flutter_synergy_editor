import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:slate/slate.dart';

TextSelection localSelection(Node node, TextSelection selection, fromParent) {
  final base = fromParent ? node.offset : node.blockOffset;
  assert(base <= selection.end && selection.start <= base + node.length - 1);

  final offset = fromParent ? node.offset : node.blockOffset;
  return selection.copyWith(
      baseOffset: math.max(selection.start - offset, 0),
      extentOffset: math.min(selection.end - offset, node.length));
  //extentOffset: math.min(selection.end - offset, node.length-1));
}


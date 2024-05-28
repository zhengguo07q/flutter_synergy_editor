// import 'package:common/common.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:thinkhub_client/workbench/theme/node_style.dart';
//
// part 'single_theme.freezed.dart';
//
//
// //    @Default(BoxConstraints.expand(width: 150, height: 100))
// //         BoxConstraints? constraints,
// //     @Default(Color(0xFFFAFAFA)) Color? backgroundColor,
// //     @Default(14) double? radius,
// //     @Default(Size.zero) Size? gap,
// //     @Default(EdgeInsets.zero) EdgeInsets? margin,
// //     @Default(EdgeInsets.all(8)) EdgeInsets? padding,
// //     @Default(0) double extensionRadiusLevel1,
// //     @Default(EdgeInsets.fromLTRB(12, 18, 12, 18))
// //         EdgeInsets extensionPaddingLevel1,
// //     @Default(0) double extensionRadiusLevel2,
// //     @Default(EdgeInsets.fromLTRB(4, 4, 4, 4)) EdgeInsets extensionPaddingLevel2,
// //     Decoration? borderDecoration,
// //     @Default(BoxDecoration()) Decoration selectedDecoration,
//
// @freezed
// class SingleTheme extends NodeTheme with _$SingleTheme {
//   const factory SingleTheme.initial({
//     @Default(BoxConstraints.expand(width: 150, height: 100))
//         BoxConstraints? constraints,
//     @Default(EdgeInsets.all(8)) EdgeInsets? margin,
//     @Default(EdgeInsets.all(8)) EdgeInsets? padding,
//
//     @Default(BoxDecoration()) Decoration borderDecoration,
//     @Default(BoxDecoration()) Decoration selectedDecoration,
//
//     @Default(BoxDecoration()) Decoration borderDecorationMajor,
//     @Default(BoxDecoration()) Decoration selectedDecorationMajor,
//
//     @Default(BoxDecoration()) Decoration borderDecorationMinor,
//     @Default(BoxDecoration()) Decoration selectedDecorationMinor,
//
//     @Default(0) double extensionRadiusLevel1,
//     @Default(EdgeInsets.fromLTRB(12, 18, 12, 18))
//         EdgeInsets extensionPaddingLevel1,
//     @Default(0) double extensionRadiusLevel2,
//     @Default(EdgeInsets.fromLTRB(4, 4, 4, 4)) EdgeInsets extensionPaddingLevel2,
//   }) = _SingleTheme;
// }
//
// extension SingleThemeExtension on SingleTheme {
//   SingleTheme toMindmap() {
//     return copyWith(
//       constraints: const BoxConstraints(
//           minWidth: 80,
//           maxWidth: 260,
//           minHeight: 0,
//           maxHeight: double.infinity),
//       margin: const EdgeInsets.all(10),
//       padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
//       borderDecoration : BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(5), ),
//       selectedDecoration: BoxDecoration(
//         border: Border.all(
//           color: Colors.amberAccent,
//           width: 4,
//         ),
//         borderRadius: BorderRadius.circular(4),
//       ),
//     );
//   }
//
//   SingleTheme toDocument() {
//     return this;
//     // return copyWith(
//     //   constraints: const BoxConstraints(
//     //     minWidth: 0,
//     //     maxWidth: double.infinity,
//     //     minHeight: 0,
//     //     maxHeight: double.infinity,
//     //   ),
//     //   selectedDecoration: BoxDecoration(
//     //     border: Border.all(
//     //       color: Colors.amberAccent,
//     //       width: 4,
//     //     ),
//     //     borderRadius: BorderRadius.circular(4),
//     //   ),
//     //   radius: 14,
//     // );
//   }
//
//   NodeTheme getNodeThemeByDepth(int depth) {
//     var thisTheme = this ;
//     if (depth == 1) {
//       return thisTheme.copyWith(
//         borderDecoration: thisTheme.borderDecoration.
//         padding: thisTheme.padding!.add(thisTheme.extensionPaddingLevel1),
//       );
//       return thisTheme.copyWith(
//         borderDecoration: thisTheme.radius! + thisTheme.extensionRadiusLevel1,
//         padding: thisTheme.padding!.add(thisTheme.extensionPaddingLevel1),
//       );
//     } else if (depth == 2) {
//       return thisTheme.copyWith(
//         radius: thisTheme.radius! + thisTheme.extensionRadiusLevel2,
//         padding: thisTheme.padding!.add(thisTheme.extensionPaddingLevel2),
//       );
//     }else{
//       return this;
//     }
//   }
// }

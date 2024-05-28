import 'package:common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'line_style.dart';
import 'node_style.dart';

final nodeThemeProvider =
    StateNotifierProvider<NodeThemeNotifier, EditorThemeData>((ref) {
  return NodeThemeNotifier();
});

class NodeThemeNotifier extends StateNotifier<EditorThemeData> {
  NodeThemeNotifier() : super((EditorThemeData.initial().toMindmap()));

  void fromMindmap() {
    state = state.toMindmap();
  }

  void fromDocument() {
    AppLogger.themeLog.i('fromDocumentBase $state');
    state = state.toDocument();
  }
}

class EditorThemeData {
  EditorThemeData({required this.nodeStyleData, required this.lineStyleData});
  final NodeStyleData nodeStyleData;
  final LineStyleData lineStyleData;

  factory EditorThemeData.initial() {
    return EditorThemeData(
      nodeStyleData: NodeStyleData(),
      lineStyleData: LineStyleData(),
    );
  }

  EditorThemeData toMindmap() {
    return EditorThemeData(
      nodeStyleData: NodeStyleData.getMindmap(),
      lineStyleData: LineStyleData.getInstance(),
    );
  }

  EditorThemeData toDocument() {
    return EditorThemeData(
      nodeStyleData: NodeStyleData.getDocument(),
      lineStyleData: LineStyleData.getInstance(),
    );
  }
}

// factory NodeThemeData({
//   ThemeLine? linePrimary,
//   ThemeLine? lineSecondary,
//   ThemeLine? lineUniversal,
//   SingleTheme? singleTheme,
// })
//
// factory NodeThemeData.initial() {
//   return NodeThemeData(
//     linePrimary: ThemeLinePrimary.initial(),
//     lineSecondary: ThemeLineSecondary.initial(),
//     lineUniversal: ThemeLineUniversal.initial(),
//     singleTheme: const SingleTheme.initial(),
//   );
// }

// static NodeThemeData toMindmap(NodeThemeData themeData) {
//   final theme = themeData.copyWith(
//     singleTheme: themeData.singleTheme!.toMindmap(),
//   );
//   AppLogger.themeLog.i('toMindmap ${theme.singleTheme}');
//   return theme;
// }
//
// static NodeThemeData toDocument(NodeThemeData themeData) {
//   final theme = themeData.copyWith(
//     singleTheme: themeData.singleTheme!.toDocument(),
//   );
//   AppLogger.themeLog.i('toDocument ${theme.singleTheme}');
//   return theme;
// }
//}

// extension NodeThemeDataExtension on NodeThemeData {
//   NodeTheme getNodeThemeByType(String type){
//     switch(type){
//       case 'single':
//         return singleTheme!;
//       default:
//         throw Error();
//     }
//   }
//
//   ThemeLine? getThemeLineByDepth(int depth) {
//     switch (depth) {
//       case 0:
//         return linePrimary;
//       case 1:
//         return lineSecondary;
//       default:
//         return lineUniversal;
//     }
//   }
// }

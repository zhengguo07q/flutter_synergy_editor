// import 'package:flutter/foundation.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
//
// import '../../main/editor_logic.dart';
//
// class ScribbleController{
//   ScribbleController({
//     required this.editorLogic,
//   });
//
//   /// 编辑器绘制器
//   final AbstractEditorLogic editorLogic;
//
//   late int _placeholderLocation = -1;
//
//   String _cachedText = '';
//   Rect? _cachedFirstRect;
//   Size _cachedSize = Size.zero;
//   int _cachedPlaceholder = -1;
//   TextStyle? _cachedTextStyle;
//
//   void updateSelectionRects({bool force = false}) {
//     final renderEditable = editorLogic.renderEditor;
//     if (!widget.scribbleEnabled) {
//       return;
//     }
//     if (defaultTargetPlatform != TargetPlatform.iOS) {
//       return;
//     }
//     // This is to avoid sending selection rects on non-iPad devices.
//     if (WidgetsBinding.instance.window.physicalSize.shortestSide < _kIPadWidth) {
//       return;
//     }
//
//     final String text = renderEditable.text?.toPlainText(includeSemanticsLabels: false) ?? '';
//     final List<Rect> firstSelectionBoxes = renderEditable.getBoxesForSelection(const TextSelection(baseOffset: 0, extentOffset: 1));
//     final Rect? firstRect = firstSelectionBoxes.isNotEmpty ? firstSelectionBoxes.first : null;
//     final ScrollDirection scrollDirection = _scrollController.position.userScrollDirection;
//     final Size size = renderEditable.size;
//     final bool textChanged = text != _cachedText;
//     final bool textStyleChanged = _cachedTextStyle != widget.style;
//     final bool firstRectChanged = _cachedFirstRect != firstRect;
//     final bool sizeChanged = _cachedSize != size;
//     final bool placeholderChanged = _cachedPlaceholder != _placeholderLocation;
//     if (scrollDirection == ScrollDirection.idle && (force || textChanged || textStyleChanged || firstRectChanged || sizeChanged || placeholderChanged)) {
//       _cachedText = text;
//       _cachedFirstRect = firstRect;
//       _cachedTextStyle = widget.style;
//       _cachedSize = size;
//       _cachedPlaceholder = _placeholderLocation;
//       bool belowRenderEditableBottom = false;
//       final List<SelectionRect> rects = List<SelectionRect?>.generate(
//         _cachedText.characters.length,
//             (int i) {
//           if (belowRenderEditableBottom) {
//             return null;
//           }
//
//           final int offset = _cachedText.characters.getRange(0, i).string.length;
//           final List<Rect> boxes = renderEditable.getBoxesForSelection(TextSelection(baseOffset: offset, extentOffset: offset + _cachedText.characters.characterAt(i).string.length));
//           if (boxes.isEmpty) {
//             return null;
//           }
//
//           final SelectionRect selectionRect = SelectionRect(
//             bounds: boxes.first,
//             position: offset,
//           );
//           if (renderEditable.paintBounds.bottom < selectionRect.bounds.top) {
//             belowRenderEditableBottom = true;
//             return null;
//           }
//           return selectionRect;
//         },
//       ).where((SelectionRect? selectionRect) {
//         if (selectionRect == null) {
//           return false;
//         }
//         if (renderEditable.paintBounds.right < selectionRect.bounds.left || selectionRect.bounds.right < renderEditable.paintBounds.left) {
//           return false;
//         }
//         if (renderEditable.paintBounds.bottom < selectionRect.bounds.top || selectionRect.bounds.bottom < renderEditable.paintBounds.top) {
//           return false;
//         }
//         return true;
//       }).map<SelectionRect>((SelectionRect? selectionRect) => selectionRect!).toList();
//       _textInputConnection!.setSelectionRects(rects);
//     }
//   }
//
//   void updateSizeAndTransform() {
//     if (hasInputConnection) {
//       final Size size = renderEditor.size;
//       final Matrix4 transform = renderEditor.getTransformTo(null);
//       _textInputConnection!.setEditableSizeAndTransform(size, transform);
//       updateSelectionRects();
//       SchedulerBinding.instance.addPostFrameCallback((Duration _) => updateSizeAndTransform());
//     } else if (_placeholderLocation != -1) {
//       removeTextPlaceholder();
//     }
//   }
//
//   void updateComposingRectIfNeeded() {
//     final TextRange composingRange = _value.composing;
//     if (hasInputConnection) {
//       assert(mounted);
//       Rect? composingRect = renderEditor.textPositionPart.getRectForComposingRange(composingRange);
//       // Send the caret location instead if there's no marked text yet.
//       if (composingRect == null) {
//         assert(!composingRange.isValid || composingRange.isCollapsed);
//         final int offset = composingRange.isValid ? composingRange.start : 0;
//         composingRect = renderEditor.textPositionPart.getLocalRectForCaret(TextPosition(offset: offset));
//       }
//       assert(composingRect != null);
//       _textInputConnection!.setComposingRect(composingRect);
//       SchedulerBinding.instance.addPostFrameCallback((Duration _) => updateComposingRectIfNeeded());
//     }
//   }
//
//   /// 提供给IOS的坐标位置
//   void updateCaretRectIfNeeded() {
//     if (hasInputConnection) {
//       if (renderEditor.selection != null && renderEditor.selection!.isValid &&
//           renderEditor.selection!.isCollapsed) {
//         final TextPosition currentTextPosition = TextPosition(offset: renderEditor.selection!.baseOffset);
//         final Rect caretRect = renderEditor.textPositionPart.getLocalRectForCaret(currentTextPosition);
//         _textInputConnection!.setCaretRect(caretRect);
//       }
//       SchedulerBinding.instance.addPostFrameCallback((Duration _) => updateCaretRectIfNeeded());
//     }
//   }
// }
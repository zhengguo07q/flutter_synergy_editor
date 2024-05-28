import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../main/editor_abstract.dart';

class ScribbleFocusable extends StatefulWidget {
  const ScribbleFocusable({
    Key? key,
    required this.child,
    required this.focusNode,
    required this.editableKey,
    required this.updateSelectionRects,
    required this.enabled,
  }) : super(key: key);

  final Widget child;
  final FocusNode focusNode;
  final GlobalKey editableKey;
  final VoidCallback updateSelectionRects;
  final bool enabled;

  @override
  _ScribbleFocusableState createState() => _ScribbleFocusableState();
}

class _ScribbleFocusableState extends State<ScribbleFocusable>
    implements ScribbleClient {
  _ScribbleFocusableState()
      : _elementIdentifier = (_nextElementIdentifier++).toString();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      TextInput.registerScribbleElement(elementIdentifier, this);
    }
  }

  @override
  void didUpdateWidget(ScribbleFocusable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled) {
      TextInput.registerScribbleElement(elementIdentifier, this);
    }

    if (oldWidget.enabled && !widget.enabled) {
      TextInput.unregisterScribbleElement(elementIdentifier);
    }
  }

  @override
  void dispose() {
    TextInput.unregisterScribbleElement(elementIdentifier);
    super.dispose();
  }

  AbstractEditorRenderBox? get renderEditable =>
      widget.editableKey.currentContext?.findRenderObject()
          as AbstractEditorRenderBox?;

  static int _nextElementIdentifier = 1;
  final String _elementIdentifier;

  @override
  String get elementIdentifier => _elementIdentifier;

  @override
  void onScribbleFocus(Offset offset) {
    widget.focusNode.requestFocus();
    renderEditable?.textSelectionPart
        .selectPositionAt(from: offset, cause: SelectionChangedCause.scribble);
    widget.updateSelectionRects();
  }

  @override
  bool isInScribbleRect(Rect rect) {
    final Rect calculatedBounds = bounds;
    if (renderEditable?.readOnly ?? false) {
      return false;
    }
    if (calculatedBounds == Rect.zero) {
      return false;
    }
    if (!calculatedBounds.overlaps(rect)) {
      return false;
    }
    final Rect intersection = calculatedBounds.intersect(rect);
    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance.hitTest(result, intersection.center);
    return result.path
        .any((HitTestEntry entry) => entry.target == renderEditable);
  }

  @override
  Rect get bounds {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !mounted || !box.attached) {
      return Rect.zero;
    }
    final Matrix4 transform = box.getTransformTo(null);
    return MatrixUtils.transformRect(
        transform, Rect.fromLTWH(0, 0, box.size.width, box.size.height));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

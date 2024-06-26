import 'package:flutter/material.dart';

/// checkbox
class PointCheckbox extends StatefulWidget {
  const PointCheckbox({
    required this.size,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.uiBuilder,
    Key? key,
  }) : super(key: key);

  final double size;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final CheckboxBuilder? uiBuilder;

  @override
  _PointCheckboxState createState() => _PointCheckboxState();
}

class _PointCheckboxState extends State<PointCheckbox> {
  @override
  Widget build(BuildContext context) {
    if (widget.uiBuilder != null) {
      return widget.uiBuilder!.build(
        context: context,
        isChecked: widget.value,
        onChanged: widget.onChanged,
      );
    }
    final theme = Theme.of(context);
    final fillColor = widget.value
        ? (widget.enabled
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.5))
        : theme.colorScheme.surface;
    final borderColor = widget.value
        ? (widget.enabled
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0))
        : (widget.enabled
            ? theme.colorScheme.onSurface.withOpacity(0.5)
            : theme.colorScheme.onSurface.withOpacity(0.3));
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Material(
          color: fillColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: InkWell(
            onTap:
                widget.enabled ? () => widget.onChanged(!widget.value) : null,
            child: widget.value
                ? Icon(Icons.check,
                    size: widget.size, color: theme.colorScheme.onPrimary)
                : null,
          ),
        ),
      ),
    );
  }
}

abstract class CheckboxBuilder {
  Widget build({
    required BuildContext context,
    required bool isChecked,
    required ValueChanged<bool> onChanged,
  });
}

import 'dart:math' as math;
import 'dart:ui';

class Diff {
  Diff(this.start, this.deleted, this.inserted);
  final int start;
  final String deleted;
  final String inserted;

  @override
  String toString() {
    return 'Diff[start$start, deleted"$deleted", inserted"$inserted"]';
  }
}

class DeltaUtil {
  static Diff getDiff(String oldText, String newText, int cursorPosition) {
    var end = oldText.length;
    final delta = newText.length - end;
    for (final limit = math.max(0, cursorPosition - delta);
        end > limit && oldText[end - 1] == newText[end + delta - 1];
        end--) {}
    var start = 0;
    for (final startLimit = cursorPosition - math.max(0, delta);
        start < startLimit && oldText[start] == newText[start];
        start++) {}
    final deleted = (start >= end) ? '' : oldText.substring(start, end);
    final inserted = newText.substring(start, end + delta);
    return Diff(start, deleted, inserted);
  }
}

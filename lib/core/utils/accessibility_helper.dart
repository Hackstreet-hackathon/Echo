import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accessibility_provider.dart';

class AccessibilityHelper {
  AccessibilityHelper._();

  static void vibrate(WidgetRef ref, {HapticFeedbackType type = HapticFeedbackType.light}) {
    final enabled = ref.read(accessibilitySettingsProvider).hapticFeedbackEnabled;
    if (enabled) {
      switch (type) {
        case HapticFeedbackType.light:
          HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          HapticFeedback.vibrate();
          break;
        case HapticFeedbackType.selection:
          HapticFeedback.selectionClick();
          break;
      }
    }
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}

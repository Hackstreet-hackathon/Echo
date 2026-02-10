import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/accessibility_provider.dart';

class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilitySettingsProvider);
    final notifier = ref.read(accessibilitySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Large Text Mode'),
            subtitle: const Text('Increase text size for readability'),
            value: settings.largeTextMode,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              notifier.setLargeTextMode(v);
            },
          ),
          SwitchListTile(
            title: const Text('High Contrast Mode'),
            subtitle: const Text('Enhanced contrast for visibility'),
            value: settings.highContrastMode,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              notifier.setHighContrastMode(v);
            },
          ),
          SwitchListTile(
            title: const Text('Voice Playback'),
            subtitle: const Text('Read announcements aloud'),
            value: settings.voicePlaybackEnabled,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              notifier.setVoicePlaybackEnabled(v);
            },
          ),
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibration on interactions'),
            value: settings.hapticFeedbackEnabled,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              notifier.setHapticFeedbackEnabled(v);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/providers.dart';
import '../../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: Text(themeMode.name),
            onTap: () {
              final modes = [ThemeMode.dark, ThemeMode.light, ThemeMode.system];
              final next =
                  modes[(modes.indexOf(themeMode) + 1) % modes.length];
              ref.read(themeModeProvider.notifier).setThemeMode(next);
            },
          ),
          ListTile(
            leading: const Icon(Icons.accessibility),
            title: const Text('Accessibility'),
            onTap: () => context.push('/accessibility'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('Version ${AppConstants.appName} 1.0.0'),
          ),
        ],
      ),
    );
  }
}

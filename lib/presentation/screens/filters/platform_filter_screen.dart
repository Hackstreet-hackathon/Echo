import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/user_profile_model.dart';
import '../../../providers/auth_provider.dart';

class PlatformFilterScreen extends ConsumerStatefulWidget {
  const PlatformFilterScreen({super.key});

  @override
  ConsumerState<PlatformFilterScreen> createState() =>
      _PlatformFilterScreenState();
}

class _PlatformFilterScreenState extends ConsumerState<PlatformFilterScreen> {
  int? _selectedPlatform;

  @override
  void initState() {
    super.initState();
    _selectedPlatform = ref.read(userProfileProvider)?.preferredPlatform;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter by Platform'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 24,
        itemBuilder: (_, i) {
          final platform = i + 1;
          final selected = _selectedPlatform == platform;
          return ListTile(
            title: Text('Platform $platform'),
            leading: Radio<int>(
              value: platform,
              groupValue: _selectedPlatform,
              onChanged: (v) => setState(() => _selectedPlatform = v),
            ),
            onTap: () {
              setState(() => _selectedPlatform = platform);
              ref.read(userProfileProvider.notifier).updateProfile(
                    (ref.read(userProfileProvider) ?? const UserProfileModel())
                        .copyWith(preferredPlatform: platform),
                  );
              context.pop();
            },
          );
        },
      ),
    );
  }
}

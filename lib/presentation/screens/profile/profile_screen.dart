import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/providers.dart';
import '../../widgets/pwd_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _getInitials(String? displayName, String? phone) {
    if (displayName != null && displayName.isNotEmpty) {
      if (displayName.length >= 1) {
        return displayName.substring(0, 1).toUpperCase();
      }
    }
    if (phone != null && phone.isNotEmpty) {
      // Phone usually starts with +, so take the next char or the first one if not +
      /* 
         Logic:
         If phone is "+12345", we probably want "1" or maybe just "#".
         But "U" is a better fallback than "+" for avatar.
         Let's just use "U" for phone numbers as initials usually don't make sense for numbers.
         OR, if we really want, we can return first digit. 
      */
       return '#'; 
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not signed in'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          _getInitials(profile?.displayName, user.phone),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (profile?.isPWD == true)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: PwdBadge(size: 28),
                              ),
                            Text(
                              profile?.displayName ?? user.phone ?? 'User',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              user.phone ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: const Icon(Icons.accessibility),
                    title: const Text('Accessibility Settings'),
                    onTap: () => context.push('/accessibility'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap: () async {
                      await ref.read(authServiceProvider).signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

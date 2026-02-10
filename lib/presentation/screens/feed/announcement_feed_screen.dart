import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/announcement_provider.dart';
import '../../../providers/providers.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/retry_button.dart';
import '../../widgets/skeleton_loader.dart';

class AnnouncementFeedScreen extends ConsumerWidget {
  const AnnouncementFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsProvider);
    final speech = ref.watch(speechServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Announcements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: announcements.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No announcements'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(announcementsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: list.length,
              itemBuilder: (_, i) => AnnouncementCard(
                announcement: list[i],
                onPlayVoice: () => speech.speak(list[i].speechRecognized),
              ),
            ),
          );
        },
        loading: () => const SkeletonLoader(),
        error: (_, __) => Center(
          child: RetryButton(
            onRetry: () => ref.read(announcementsProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}

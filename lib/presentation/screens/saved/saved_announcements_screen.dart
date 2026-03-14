import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/saved_announcements_provider.dart';
import '../../../providers/providers.dart';
import '../../widgets/announcement_card.dart';

class SavedAnnouncementsScreen extends ConsumerWidget {
  const SavedAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedAnnouncementsProvider);
    final speech = ref.watch(speechServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Announcements'),
      ),
      body: savedAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No saved announcements yet'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final ann = list[index];
              return AnnouncementCard(
                announcement: ann,
                isFavorite: true,
                onFavorite: () => ref.read(savedAnnouncementsProvider.notifier).toggleSave(ann),
                onPlayVoice: () => speech.speak(ann.speechRecognized),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

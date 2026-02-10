import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/announcement_model.dart';
import '../../../providers/announcement_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/providers.dart';
import '../../../providers/speech_capture_provider.dart';
import '../../widgets/announcement_banner.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/retry_button.dart';
import '../../widgets/skeleton_loader.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  AnnouncementModel? _latestBanner;
  bool _bannerDismissed = false;

  @override
  void initState() {
    super.initState();
  }

  void _playVoice(String text) {
    ref.read(speechServiceProvider).speak(text);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to realtime announcements from Supabase for the banner.
    ref.listen(announcementsRealtimeProvider, (prev, next) {
      next.whenData((list) {
        if (list.isNotEmpty && !_bannerDismissed) {
          setState(() => _latestBanner = list.first);
        }
      });
    });

    final announcements = ref.watch(announcementsRealtimeProvider);
    final liveSpeech = ref.watch(liveSpeechCaptureProvider);
    final connectivity = ref.watch(connectivityServiceProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('ECHO'),
        actions: [
          if (!connectivity.isConnected)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('Offline', style: TextStyle(fontSize: 12)),
                backgroundColor: AppColors.warning.withOpacity(0.2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/feed'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => context.push('/train-filter'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_latestBanner != null && !_bannerDismissed)
            AnnouncementBanner(
              announcement: _latestBanner!,
              onDismiss: () => setState(() => _bannerDismissed = true),
              onPlayVoice: () => _playVoice(_latestBanner!.speechRecognized),
            ),
          Expanded(
            child: announcements.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 64,
                          color: AppColors.textSecondaryDark,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No announcements yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pull to refresh when connected',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 24),
                        RetryButton(
                          onRetry: () =>
                              ref.invalidate(announcementsRealtimeProvider),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(announcementsRealtimeProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final a = list[i];
                      return AnnouncementCard(
                        announcement: a,
                        onPlayVoice: () => _playVoice(a.speechRecognized),
                        onFavorite: () async {
                          await ref
                              .read(cacheServiceProvider)
                              .addToFavorites(a);
                          await ref
                              .read(cacheServiceProvider)
                              .addToHistory(a);
                        },
                        showPwdBadge: true,
                      );
                    },
                  ),
                );
              },
              loading: () => const SkeletonLoader(),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    RetryButton(
                      onRetry: () =>
                          ref.read(announcementsProvider.notifier).refresh(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            ref.read(liveSpeechCaptureProvider.notifier).toggle(),
        icon: Icon(
          liveSpeech.isListening ? Icons.mic_off : Icons.mic,
        ),
        label: Text(liveSpeech.isListening ? 'Stop listening' : 'Live capture'),
      ),
    );
  }
}

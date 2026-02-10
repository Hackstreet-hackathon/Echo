import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/announcement_model.dart';
import '../../../providers/providers.dart';
import '../../../services/cache/cache_service.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/empty_state.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<AnnouncementModel> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cache = ref.read(cacheServiceProvider);
    final list = await cache.getFavorites();
    if (mounted) setState(() {
      _favorites = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _favorites.isEmpty
          ? EmptyState(
              icon: Icons.bookmark_border,
              title: 'No favorites yet',
              message: 'Bookmark announcements to find them here',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _favorites.length,
                itemBuilder: (_, i) {
                  final a = _favorites[i];
                  return AnnouncementCard(
                    announcement: a,
                    isFavorite: true,
                    onFavorite: () async {
                      final key = a.id ??
                          '${a.time}_${a.speechRecognized.hashCode}';
                      await ref
                          .read(cacheServiceProvider)
                          .removeFromFavorites(key);
                      _load();
                    },
                    onPlayVoice: () =>
                        ref.read(speechServiceProvider).speak(a.speechRecognized),
                  );
                },
              ),
            ),
    );
  }
}

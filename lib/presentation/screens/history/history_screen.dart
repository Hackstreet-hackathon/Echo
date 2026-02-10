import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/announcement_model.dart';
import '../../../providers/providers.dart';
import '../../../services/cache/cache_service.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/empty_state.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<AnnouncementModel> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cache = ref.read(cacheServiceProvider);
    final list = await cache.getHistory();
    if (mounted) setState(() {
      _history = list;
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
        title: const Text('History'),
      ),
      body: _history.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              title: 'No history yet',
              message: 'Viewed announcements will appear here',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _history.length,
                itemBuilder: (_, i) => AnnouncementCard(
                  announcement: _history[i],
                  onPlayVoice: () => ref
                      .read(speechServiceProvider)
                      .speak(_history[i].speechRecognized),
                ),
              ),
            ),
    );
  }
}

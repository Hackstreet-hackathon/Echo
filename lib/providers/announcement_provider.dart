import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/announcement_model.dart';
import '../providers/providers.dart';
import '../services/api/api_service.dart';
import '../services/cache/cache_service.dart';
import '../services/connectivity/connectivity_service.dart';

final announcementsProvider =
    StateNotifierProvider<AnnouncementsNotifier, AsyncValue<List<AnnouncementModel>>>(
  (ref) {
    final api = ref.watch(apiServiceProvider);
    final cache = ref.watch(cacheServiceProvider);
    final connectivity = ref.watch(connectivityServiceProvider);
    return AnnouncementsNotifier(api, cache, connectivity);
  },
);

class AnnouncementsNotifier
    extends StateNotifier<AsyncValue<List<AnnouncementModel>>> {
  AnnouncementsNotifier(this._api, this._cache, this._connectivity)
      : super(const AsyncValue.loading()) {
    load();
  }

  final ApiService _api;
  final CacheService _cache;
  final ConnectivityService _connectivity;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final connected = await _connectivity.checkConnection();
      List<AnnouncementModel> list;
      if (connected) {
        list = await _api.getAnnouncements();
        await _cache.cacheAnnouncements(list);
      } else {
        list = await _cache.getCachedAnnouncements();
      }
      
      // Sort by priority: High > Medium > Low
      list.sort((a, b) {
        final pA = _getPriorityValue(a.priority);
        final pB = _getPriorityValue(b.priority);
        return pB.compareTo(pA); // Descending order
      });
      
      state = AsyncValue.data(list);
    } catch (e, st) {
      final cached = await _cache.getCachedAnnouncements();
      if (cached.isNotEmpty) {
        state = AsyncValue.data(cached);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> refresh() => load();

  int _getPriorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
      default:
        return 1;
    }
  }
}

/// Realtime announcements stream from Supabase.
///
/// This listens to changes on the `announcements` table and emits a
/// sorted list (by priority, then time) whenever new data arrives.
final announcementsRealtimeProvider =
    StreamProvider<List<AnnouncementModel>>((ref) {
  final client = Supabase.instance.client;
  final filter = ref.watch(trainFilterProvider);

  return client
      .from('announcements')
      .stream(primaryKey: ['id'])
      .order('time', ascending: false)
      .map((rows) {
    var list = rows
        .map((row) => AnnouncementModel.fromJson(
              Map<String, dynamic>.from(row),
            ))
        .toList();

    // Filter by train number if search is active
    if (filter != 'All' && filter.isNotEmpty) {
      list = list.where((a) {
        final trainNo = a.ticket?.trainNo ?? '';
        return trainNo.contains(filter) || filter.contains(trainNo);
      }).toList();
    }

    // Sort by priority: High > Medium > Low
    list.sort((a, b) {
      int p(String pr) {
        switch (pr.toLowerCase()) {
          case 'high':
            return 3;
          case 'medium':
            return 2;
          case 'low':
          default:
            return 1;
        }
      }

      final pA = p(a.priority);
      final pB = p(b.priority);
      return pB.compareTo(pA);
    });

    return list;
  });
});


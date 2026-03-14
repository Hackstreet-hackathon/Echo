import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/announcement_model.dart';
import 'providers.dart';

final savedAnnouncementsProvider = StateNotifierProvider<SavedAnnouncementsNotifier, AsyncValue<List<AnnouncementModel>>>((ref) {
  final api = ref.watch(apiServiceProvider);
  return SavedAnnouncementsNotifier(api);
});

class SavedAnnouncementsNotifier extends StateNotifier<AsyncValue<List<AnnouncementModel>>> {
  SavedAnnouncementsNotifier(this._api) : super(const AsyncValue.loading()) {
    load();
  }

  final _api;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _api.getSavedAnnouncements();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleSave(AnnouncementModel announcement) async {
    final currentList = state.value ?? [];
    final isSaved = currentList.any((e) => e.id == announcement.id);

    try {
      if (isSaved) {
        await _api.unsaveAnnouncement(announcement.id!);
        state = AsyncValue.data(currentList.where((e) => e.id != announcement.id).toList());
      } else {
        await _api.saveAnnouncement(announcement.id!);
        // We could fetch again or just optimistically update. 
        // Fetching again is safer to ensure we have any metadata from the join table if needed.
        await load();
      }
    } catch (e) {
      // Revert or show error handle
    }
  }

  bool isSaved(String announcementId) {
    return state.value?.any((e) => e.id == announcementId) ?? false;
  }
}

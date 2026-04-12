import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../../data/models/announcement_model.dart';

/// Service for fetching data from Supabase
class ApiService {
  ApiService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final data = await _client.from('announcements').select().order('created_at', ascending: false);
      if (data is List) {
        return data.map((e) => AnnouncementModel.fromJson(e)).toList();
      }
      return [];
    } catch (e, s) {
      AppLogger.debug('getAnnouncements failed', e, s);
      rethrow;
    }
  }

  Future<AnnouncementModel?> getAnnouncementByName(String name) async {
    try {
      final data = await _client
          .from('announcements')
          .select()
          .eq('name', name)
          .maybeSingle();

      if (data != null) {
        return AnnouncementModel.fromJson(data);
      }
      return null;
    } catch (e, s) {
      AppLogger.debug('getAnnouncementByName failed', e, s);
      rethrow;
    }
  }

  Future<List<AnnouncementModel>> getPlatformAnnouncements(int platformNum) async {
    try {
      final data = await _client
          .from('announcements')
          .select()
          .eq('platform', platformNum)
          .order('created_at', ascending: false);
      
      if (data is List) {
        return data.map((e) => AnnouncementModel.fromJson(e)).toList();
      }
      return [];
    } catch (e, s) {
      AppLogger.debug('getPlatformAnnouncements failed', e, s);
      rethrow;
    }
  }

  Future<void> uploadAnnouncement(Map<String, dynamic> payload) async {
    try {
       await _client.from('announcements').insert(payload);
    } catch (e, s) {
      AppLogger.debug('uploadAnnouncement failed', e, s);
      rethrow;
    }
  }

  Future<void> deleteAllAnnouncements() async {
    try {
      await _client.from('announcements').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (e, s) {
      AppLogger.debug('deleteAllAnnouncements failed', e, s);
      rethrow;
    }
  }

  Future<void> saveAnnouncement(String announcementId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _client.from('saved_announcements').upsert({
        'user_id': user.id,
        'announcement_id': announcementId,
      });
    } catch (e, s) {
      AppLogger.debug('saveAnnouncement failed', e, s);
      rethrow;
    }
  }

  Future<void> unsaveAnnouncement(String announcementId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client
          .from('saved_announcements')
          .delete()
          .eq('user_id', user.id)
          .eq('announcement_id', announcementId);
    } catch (e, s) {
      AppLogger.debug('unsaveAnnouncement failed', e, s);
      rethrow;
    }
  }

  Future<List<AnnouncementModel>> getSavedAnnouncements() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _client
          .from('saved_announcements')
          .select('announcements(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (data is List) {
        return data
            .map((e) {
              final announcementData = e['announcements'];
              if (announcementData != null) {
                return AnnouncementModel.fromJson(announcementData as Map<String, dynamic>);
              }
              return null;
            })
            .whereType<AnnouncementModel>()
            .toList();
      }
      return [];
    } catch (e, s) {
      AppLogger.debug('getSavedAnnouncements failed', e, s);
      rethrow;
    }
  Future<Map<String, dynamic>?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      return await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
    } catch (e, s) {
      AppLogger.debug('getProfile failed', e, s);
      return null; // Return null on error to avoid breaking things
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _client.from('user_profiles').update(data).eq('id', user.id);
    } catch (e, s) {
      AppLogger.debug('updateProfile failed', e, s);
      rethrow;
    }
  }
}

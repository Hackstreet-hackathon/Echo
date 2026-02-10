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
}

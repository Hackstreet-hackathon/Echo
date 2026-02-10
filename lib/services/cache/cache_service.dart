import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart' as app_utils;
import '../../core/utils/logger.dart';
import '../../data/models/announcement_model.dart';

/// Local cache service using Hive for offline support
class CacheService {
  CacheService();

  static Box<dynamic>? _announcementsBox;
  static Box<dynamic>? _favoritesBox;
  static Box<dynamic>? _historyBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _announcementsBox ??=
        await Hive.openBox<dynamic>(AppConstants.announcementsBoxName);
    _favoritesBox ??=
        await Hive.openBox<dynamic>(AppConstants.favoritesBoxName);
    _historyBox ??= await Hive.openBox<dynamic>(AppConstants.historyBoxName);
  }

  Future<void> cacheAnnouncements(List<AnnouncementModel> announcements) async {
    try {
      final encoded = announcements
          .map((a) => jsonEncode(a.toJson()))
          .toList();
      await _announcementsBox?.put('list', encoded);
      await _announcementsBox?.put('cached_at', DateTime.now().toIso8601String());
    } catch (e, s) {
      AppLogger.debug('cacheAnnouncements failed', e, s);
    }
  }

  Future<List<AnnouncementModel>> getCachedAnnouncements() async {
    try {
      final list = _announcementsBox?.get('list');
      if (list is! List) return [];
      return list
          .map((e) => AnnouncementModel.fromJson(
              jsonDecode(e as String) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  bool get hasCachedAnnouncements {
    final list = _announcementsBox?.get('list');
    return list is List && list.isNotEmpty;
  }

  DateTime? get lastCacheTime {
    final s = _announcementsBox?.get('cached_at') as String?;
    return app_utils.AppDateUtils.parseIso8601(s);
  }

  Future<void> addToFavorites(AnnouncementModel announcement) async {
    try {
      final key = announcement.id ?? '${announcement.time}_${announcement.speechRecognized.hashCode}';
      await _favoritesBox?.put(key, jsonEncode(announcement.toJson()));
    } catch (e, s) {
      AppLogger.debug('addToFavorites failed', e, s);
    }
  }

  Future<void> removeFromFavorites(String id) async {
    await _favoritesBox?.delete(id);
  }

  Future<List<AnnouncementModel>> getFavorites() async {
    try {
      final keys = _favoritesBox?.keys.cast<String>().toList() ?? [];
      return keys
          .map((k) {
            final v = _favoritesBox?.get(k);
            if (v is String) {
              return AnnouncementModel.fromJson(
                  jsonDecode(v) as Map<String, dynamic>);
            }
            return null;
          })
          .whereType<AnnouncementModel>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addToHistory(AnnouncementModel announcement) async {
    try {
      final key = DateTime.now().millisecondsSinceEpoch.toString();
      await _historyBox?.put(key, jsonEncode(announcement.toJson()));
      final keys = _historyBox?.keys.toList() ?? [];
      if (keys.length > AppConstants.maxHistoryItems) {
        keys.sort();
        for (var i = 0; i < keys.length - AppConstants.maxHistoryItems; i++) {
          await _historyBox?.delete(keys[i]);
        }
      }
    } catch (e, s) {
      AppLogger.debug('addToHistory failed', e, s);
    }
  }

  Future<List<AnnouncementModel>> getHistory() async {
    try {
      final keys = _historyBox?.keys.toList() ?? [];
      keys.sort((a, b) => b.toString().compareTo(a.toString()));
      return keys
          .map((k) {
            final v = _historyBox?.get(k);
            if (v is String) {
              return AnnouncementModel.fromJson(
                  jsonDecode(v) as Map<String, dynamic>);
            }
            return null;
          })
          .whereType<AnnouncementModel>()
          .toList();
    } catch (_) {
      return [];
    }
  }
}

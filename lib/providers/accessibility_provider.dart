import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/storage_keys.dart';
import '../data/models/accessibility_settings_model.dart';
import '../providers/providers.dart';
import '../services/storage/preferences_service.dart';

final accessibilitySettingsProvider =
    StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettingsModel>(
  (ref) {
    final prefs = ref.watch(preferencesServiceProvider);
    final api = ref.watch(apiServiceProvider);
    
    final stored = prefs.getString(StorageKeys.accessibilitySettings);
    AccessibilitySettingsModel settings = const AccessibilitySettingsModel();
    if (stored != null) {
      try {
        settings =
            AccessibilitySettingsModel.fromJson(
                jsonDecode(stored) as Map<String, dynamic>);
      } catch (_) {}
    }
    
    final notifier = AccessibilitySettingsNotifier(prefs, api, settings);
    
    // Listen to auth changes to sync/reset settings
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((state) {
        if (state.event == AuthChangeEvent.signedIn) {
          notifier.loadFromSupabase();
        } else if (state.event == AuthChangeEvent.signedOut) {
          notifier.reset();
        }
      });
    });

    return notifier;
  },
);

class AccessibilitySettingsNotifier
    extends StateNotifier<AccessibilitySettingsModel> {
  AccessibilitySettingsNotifier(this._prefs, this._api, super.initialState);

  final PreferencesService _prefs;
  final ApiService _api;

  void _persist() {
    _prefs.setString(
        StorageKeys.accessibilitySettings, jsonEncode(state.toJson()));
  }

  Future<void> syncToSupabase() async {
    try {
      await _api.updateProfile({
        'accessibility_settings': state.toJson(),
      });
    } catch (e) {
      // Just log, don't break the UI
      AppLogger.debug('Failed to sync settings to Supabase', e);
    }
  }

  Future<void> loadFromSupabase() async {
    try {
      final profile = await _api.getProfile();
      if (profile != null && profile['accessibility_settings'] != null) {
        state = AccessibilitySettingsModel.fromJson(
            profile['accessibility_settings'] as Map<String, dynamic>);
        _persist();
      }
    } catch (e) {
      AppLogger.debug('Failed to load settings from Supabase', e);
    }
  }

  void reset() {
    state = const AccessibilitySettingsModel();
    _prefs.remove(StorageKeys.accessibilitySettings);
  }

  void update(AccessibilitySettingsModel settings) {
    state = settings;
    _persist();
    syncToSupabase();
  }

  void setLargeTextMode(bool value) {
    state = state.copyWith(largeTextMode: value);
    _persist();
    syncToSupabase();
  }

  void setHighContrastMode(bool value) {
    state = state.copyWith(highContrastMode: value);
    _persist();
    syncToSupabase();
  }

  void setVoicePlaybackEnabled(bool value) {
    state = state.copyWith(voicePlaybackEnabled: value);
    _persist();
    syncToSupabase();
  }

  void setHapticFeedbackEnabled(bool value) {
    state = state.copyWith(hapticFeedbackEnabled: value);
    _persist();
    syncToSupabase();
  }
}

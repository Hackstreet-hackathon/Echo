import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/utils/logger.dart';
import '../../data/models/user_profile_model.dart';
import '../storage/preferences_service.dart';

/// Auth service using Supabase
class AuthService {
  AuthService({
    SupabaseClient? client,
    PreferencesService? preferences,
  })  : _client = client ?? Supabase.instance.client,
        _preferences = preferences ?? PreferencesService();

  final SupabaseClient _client;
  final PreferencesService _preferences;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with phone number and send OTP
  Future<void> signUpWithPhone({
    required String phone,
    String? displayName,
    bool isPWD = false,
    String? disabilityDetails,
  }) async {
    try {
      final metadata = <String, dynamic>{
        if (displayName != null) 'display_name': displayName,
        'isPWD': isPWD,
        if (disabilityDetails != null) 'disability_details': disabilityDetails,
      };
      
      await _client.auth.signInWithOtp(
        phone: phone,
        data: metadata.isNotEmpty ? metadata : null,
      );
    } on AuthException catch (e, s) {
      AppLogger.debug('signUpWithPhone failed', e, s);
      rethrow;
    }
  }

  /// Sign in with phone number and send OTP
  Future<void> signInWithPhone({
    required String phone,
  }) async {
    try {
      await _client.auth.signInWithOtp(
        phone: phone,
      );
    } on AuthException catch (e, s) {
      AppLogger.debug('signInWithPhone failed', e, s);
      rethrow;
    }
  }

  /// Verify OTP code
  Future<void> verifyOTP({
    required String phone,
    required String token,
  }) async {
    try {
      await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
    } on AuthException catch (e, s) {
      AppLogger.debug('verifyOTP failed', e, s);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    await _preferences.remove(StorageKeys.userProfile);
  }

  UserProfileModel? getCachedProfile() {
    final json = _preferences.getString(StorageKeys.userProfile);
    if (json == null) return null;
    try {
      return UserProfileModel.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheProfile(UserProfileModel profile) async {
    await _preferences.setString(
      StorageKeys.userProfile,
      jsonEncode(profile.toJson()),
    );
  }
}

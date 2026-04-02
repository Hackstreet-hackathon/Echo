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
    AppLogger.debug('Attempting signUpWithPhone for: $phone');
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
      AppLogger.debug('OTP sent successfully for signup to: $phone');
    } on AuthException catch (e, s) {
      AppLogger.debug('signUpWithPhone failed: ${e.message}', e, s);
      throw Exception(e.message);
    } catch (e, s) {
      AppLogger.debug('An unexpected error occurred during signUpWithPhone', e, s);
      throw Exception('Failed to send verification code. Please try again.');
    }
  }

  /// Sign in with phone number and send OTP
  Future<void> signInWithPhone({
    required String phone,
  }) async {
    AppLogger.debug('Attempting signInWithPhone for: $phone');
    try {
      await _client.auth.signInWithOtp(
        phone: phone,
      );
      AppLogger.debug('OTP sent successfully for signin to: $phone');
    } on AuthException catch (e, s) {
      AppLogger.debug('signInWithPhone failed: ${e.message}', e, s);
      throw Exception(e.message);
    } catch (e, s) {
      AppLogger.debug('An unexpected error occurred during signInWithPhone', e, s);
      throw Exception('Failed to send verification code. Please try again.');
    }
  }

  /// Verify OTP code
  Future<void> verifyOTP({
    required String phone,
    required String token,
  }) async {
    AppLogger.debug('Attempting verifyOTP for: $phone with token: $token');
    try {
      await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      AppLogger.debug('OTP verified successfully for: $phone');
    } on AuthException catch (e, s) {
      AppLogger.debug('verifyOTP failed: ${e.message}', e, s);
      throw Exception(e.message);
    } catch (e, s) {
      AppLogger.debug('An unexpected error occurred during verifyOTP', e, s);
      throw Exception('Verification failed. Please check the code and try again.');
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/user_profile_model.dart';
import '../providers/providers.dart';
import '../services/auth/auth_service.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileModel?>((ref) {
  final auth = ref.watch(authServiceProvider);
  final notifier = UserProfileNotifier(auth);
  
  // Listen to auth changes and update profile
  ref.listen(authStateProvider, (previous, next) {
    next.whenData((state) {
      if (state.event == AuthChangeEvent.signedIn || state.event == AuthChangeEvent.tokenRefreshed) {
        notifier.loadFromAuth();
      } else if (state.event == AuthChangeEvent.signedOut) {
        notifier.clearProfile();
      }
    });
  });

  return notifier;
});

class UserProfileNotifier extends StateNotifier<UserProfileModel?> {
  UserProfileNotifier(this._auth) : super(_auth.getCachedProfile());

  final AuthService _auth;

  void updateProfile(UserProfileModel profile) {
    state = profile;
    _auth.cacheProfile(profile);
  }

  void clearProfile() {
    state = null;
  }

  void loadFromAuth() {
    final user = _auth.currentUser;
    if (user != null) {
      state = (state ?? const UserProfileModel()).copyWith(
        id: user.id,
        phone: user.phone,
        displayName: user.userMetadata?['display_name'] as String?,
        isPWD: (user.userMetadata?['isPWD'] as bool?) ?? false,
        disabilityDetails: user.userMetadata?['disability_details'] as String?,
      );
    }
  }
}

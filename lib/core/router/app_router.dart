import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/accessibility/accessibility_settings_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_verification_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/error/error_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/notification/notification_center_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/feed/announcement_feed_screen.dart';
import '../../presentation/screens/filters/platform_filter_screen.dart';
import '../../presentation/screens/filters/train_filter_screen.dart';
import '../../presentation/screens/saved/saved_announcements_screen.dart';
import '../../presentation/widgets/main_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (_, state) => OtpVerificationScreen(
          phoneNumber: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/error',
        builder: (_, __) => const ErrorScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (_, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
            routes: [
              GoRoute(
                path: 'feed',
                builder: (_, __) => const AnnouncementFeedScreen(),
              ),
              GoRoute(
                path: 'train-filter',
                builder: (_, __) => const TrainFilterScreen(),
              ),
              GoRoute(
                path: 'platform-filter',
                builder: (_, __) => const PlatformFilterScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/saved-announcements',
            builder: (_, __) => const SavedAnnouncementsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (_, __) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationCenterScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/accessibility',
            builder: (_, __) => const AccessibilitySettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

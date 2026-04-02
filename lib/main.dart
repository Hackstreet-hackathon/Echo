import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/router/app_router.dart';
import 'providers/theme_provider.dart';
import 'services/cache/cache_service.dart';
import 'services/notification/notification_service.dart';
import 'services/storage/preferences_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppSetup());
}

class AppSetup extends StatefulWidget {
  const AppSetup({super.key});

  @override
  State<AppSetup> createState() => _AppSetupState();
}

class _AppSetupState extends State<AppSetup> {
  bool _isInitialized = false;
  String _statusMessage = 'Starting...';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    setState(() {
      _errorMessage = null;
      _statusMessage = '🚀 Starting initialization...';
    });

    try {
      // 1. Preferences
      setState(() => _statusMessage = '📦 Initializing Preferences...');
      await PreferencesService.ensureInit();

      // 2. Hive
      setState(() => _statusMessage = '📦 Initializing Local Database...');
      await Hive.initFlutter();

      // 3. Cache
      setState(() => _statusMessage = '📦 Initializing Cache...');
      await CacheService.init();

      // 4. Environment
      setState(() => _statusMessage = '🔑 Loading Configuration...');
      await dotenv.load(fileName: ".env");

      // 5. Supabase
      setState(() => _statusMessage = '⚡ Connecting to Cloud...');
      // debugPrint('Connecting to Supabase: ${dotenv.env['SUPABASE_URL']}');

      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? "https://tzxhevtpeerooqmmriuk.supabase.co",
        anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? "sb_publishable_VAsQyXuddxZOkHgmtu-m7w_3hy28bDV",
      );

      // 6. Notifications
      setState(() => _statusMessage = '🔔 Setting up Notifications...');
      await NotificationService().init();

      // 7. UI System Overlay
      setState(() => _statusMessage = '🎨 Finalizing UI...');
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF0D1117),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Done
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, st) {
      debugPrint('Initialization failed: $e\n$st');
      if (mounted) {
        setState(() {
          _errorMessage = 'Initialization failed:\n$e';
          _statusMessage = 'Error occurred';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      return const ProviderScope(child: EchoApp());
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Use dark theme for splash/loading
      home: Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Icon
                const Icon(
                  Icons.multitrack_audio_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'ECHO',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),

                // Content based on state
                if (_errorMessage != null) ...[
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _initApp,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ] else ...[
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EchoApp extends ConsumerWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = createAppRouter();

    return MaterialApp.router(
      title: 'ECHO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

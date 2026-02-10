import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/retry_button.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 80,
                color: AppColors.textSecondaryDark,
              ),
              const SizedBox(height: 24),
              Text(
                'No Network',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                message ??
                    'Please check your connection and try again. ECHO works offline with cached data.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              RetryButton(
                onRetry: () => context.go('/'),
                label: 'Try Again',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

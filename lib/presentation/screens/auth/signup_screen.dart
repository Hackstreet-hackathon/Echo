import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _disabilityDetailsController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _hasDisability;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _disabilityDetailsController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      final isPWD = _hasDisability == 'Yes';
      final phoneNumber = _phoneController.text.trim();
      
      // Ensure phone starts with +
      final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';
      
      await auth.signUpWithPhone(
        phone: formattedPhone,
        displayName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        isPWD: isPWD,
        disabilityDetails: isPWD ? _disabilityDetailsController.text.trim() : null,
      );
      
      if (mounted) {
        context.push('/otp-verification', extra: formattedPhone);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join ECHO for personalized announcements',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name (optional)',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '+919876543210',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your phone number';
                    if (!v.startsWith('+')) return 'Phone must start with country code (e.g., +91)';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _hasDisability,
                  decoration: const InputDecoration(
                    labelText: 'Do you have a disability?',
                    prefixIcon: Icon(Icons.accessible_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _hasDisability = value;
                      if (value != 'Yes') {
                        _disabilityDetailsController.clear();
                      }
                    });
                  },
                  validator: (v) => v == null ? 'Please select an option' : null,
                ),
                if (_hasDisability == 'Yes') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _disabilityDetailsController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      labelText: 'Please specify your disability',
                      prefixIcon: Icon(Icons.info_outlined),
                      hintText: 'e.g., Visual impairment, Hearing impairment',
                    ),
                    maxLines: 2,
                    validator: (v) {
                      if (_hasDisability == 'Yes' && (v == null || v.trim().isEmpty)) {
                        return 'Please provide disability details';
                      }
                      return null;
                    },
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send OTP'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Already have an account? Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

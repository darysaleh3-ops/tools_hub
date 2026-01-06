import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/auth_notifier.dart';

class OTPScreen extends ConsumerStatefulWidget {
  const OTPScreen({super.key});

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تحقق من الرقم',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'أدخل رمز التأكيد المرسل إلى جوالك',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(
                  hintText: '******',
                  hintStyle: TextStyle(letterSpacing: 8),
                ),
              ),
              if (authState.status == AuthStatus.error) ...[
                const SizedBox(height: 16),
                Text(
                  authState.errorMessage ?? 'حدث خطأ ما',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authState.status == AuthStatus.authenticating
                    ? null
                    : () {
                        if (_otpController.text.length == 6) {
                          ref
                              .read(authProvider.notifier)
                              .verifyOTP(_otpController.text);
                        }
                      },
                child: authState.status == AuthStatus.authenticating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تأكيد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

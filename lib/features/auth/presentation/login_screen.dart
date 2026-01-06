import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for codeSent state to navigate to OTP screen
    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.codeSent) {
        context.push('/otp');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً بك في Tools Hub',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'أدخل رقم جوالك للمتابعة',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  hintText: '5xxxxxxxx',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      '+966 ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
                        final phone = _phoneController.text.trim();
                        if (phone.isNotEmpty) {
                          ref.read(authProvider.notifier).sendOTP('+966$phone');
                        }
                      },
                child: authState.status == AuthStatus.authenticating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إرسال رمز التأكيد'),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: authState.status == AuthStatus.authenticating
                      ? null
                      : () =>
                            ref.read(authProvider.notifier).signInAnonymously(),
                  child: const Text(
                    'تخطي والدخول كضيف',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

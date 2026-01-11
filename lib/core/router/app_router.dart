import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/auth_notifier.dart';
import '../../features/auth/domain/user_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/equipment/presentation/home_screen.dart';
import '../../features/equipment/presentation/equipment_details_screen.dart';
import '../../features/admin/presentation/admin_layout.dart';
import '../../features/admin/presentation/dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final userProfileAsync = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // 1. Auth Guard (Existing)
      if (authState.status == AuthStatus.authenticating) return null;

      final loggedIn = authState.status == AuthStatus.authenticated;
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/';

      // 2. Admin Guard
      if (state.matchedLocation.startsWith('/admin')) {
        // If profile is still loading, let it stay (it matches /admin so it shows loading/shell)
        // Once loaded, if not admin -> Redirect to Home
        if (!userProfileAsync.isLoading) {
          final user = userProfileAsync.asData?.value;
          if (user == null || !user.isAdmin) {
            return '/';
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/otp', builder: (context, state) => const OTPScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/equipment/:id',
        builder: (context, state) =>
            EquipmentDetailsScreen(id: state.pathParameters['id']!),
      ),
      // Admin Routes
      ShellRoute(
        builder: (context, state, child) {
          // Optional: Show loading if profile is fetching
          if (userProfileAsync.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return AdminLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/admin/equipment',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('إدارة المعدات (قريباً)')),
            ),
          ),
        ],
      ),
    ],
  );
});

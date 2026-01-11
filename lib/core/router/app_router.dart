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
import '../../features/admin/presentation/admin_register_screen.dart';
import '../../features/admin/presentation/admin_approval_screen.dart';
import '../../features/admin/presentation/admin_layout.dart';
import '../../features/admin/presentation/dashboard_screen.dart';
import '../../features/admin/presentation/admin_login_screen.dart';

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
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/admin-register' || // Allow public access
          state.matchedLocation ==
              '/admin-approval' || // Allow semi-protected access
          state.matchedLocation == '/admin-login';

      // Not logged in
      if (!loggedIn && !loggingIn) {
        // If trying to access admin area, send to admin login
        if (state.matchedLocation.startsWith('/admin')) {
          return '/admin-login';
        }
        return '/login';
      }

      // Logged in
      if (loggedIn && loggingIn) {
        if (state.matchedLocation == '/admin-approval') {
          // Let logic below handle approval check
        } else if (state.matchedLocation == '/admin-login') {
          return '/admin';
        } else {
          return '/';
        }
      }

      // 2. Admin Guard
      if (state.matchedLocation.startsWith('/admin')) {
        // Public/Semi-protected admin pages
        if (state.matchedLocation == '/admin-register' ||
            state.matchedLocation == '/admin-login')
          return null;

        if (!userProfileAsync.isLoading) {
          final user = userProfileAsync.asData?.value;

          if (user == null || !user.isAdmin) {
            return '/';
          }

          if (state.matchedLocation != '/admin-approval' && !user.isActive) {
            return '/admin-approval';
          }

          if (state.matchedLocation == '/admin-approval' && user.isActive) {
            return '/admin';
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/admin-register',
        builder: (context, state) => const AdminRegisterScreen(),
      ),
      GoRoute(
        path: '/admin-approval',
        builder: (context, state) => const AdminApprovalScreen(),
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

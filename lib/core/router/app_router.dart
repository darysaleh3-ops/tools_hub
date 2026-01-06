import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/auth_notifier.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/equipment/presentation/home_screen.dart';
import '../../features/equipment/presentation/equipment_details_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = authState.status == AuthStatus.authenticated;
      final loggingIn =
          state.matchedLocation == '/login' || state.matchedLocation == '/otp';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OTPScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/equipment/:id',
        builder: (context, state) =>
            EquipmentDetailsScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
});

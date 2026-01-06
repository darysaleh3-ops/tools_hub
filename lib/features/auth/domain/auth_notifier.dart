import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  authenticating,
  codeSent,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final String? verificationId;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.verificationId,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.unauthenticated);

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? verificationId,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  bool get isAnonymous => user?.isAnonymous ?? false;
}

// Stream provider for raw firebase auth changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Watch raw stream and update internal state status
    final authStream = ref.watch(authStateChangesProvider);

    return authStream.when(
      data: (user) {
        if (user != null) {
          return AuthState(status: AuthStatus.authenticated, user: user);
        }
        return AuthState.initial();
      },
      loading: () => AuthState(status: AuthStatus.authenticating),
      error: (e, s) =>
          AuthState(status: AuthStatus.error, errorMessage: e.toString()),
    );
  }

  Future<void> sendOTP(String phoneNumber) async {
    final repository = ref.read(authRepositoryProvider);
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      await repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (verificationId, resendToken) {
          state = state.copyWith(
            status: AuthStatus.codeSent,
            verificationId: verificationId,
          );
        },
        verificationFailed: (e) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: e.message,
          );
        },
        verificationCompleted: (credential) async {
          await repository.signInWithCredential(credential);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // Handle timeout if needed
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> verifyOTP(String smsCode) async {
    final repository = ref.read(authRepositoryProvider);
    if (state.verificationId == null) return;
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );
      await repository.signInWithCredential(credential);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'رمز التحقق غير صحيح',
      );
    }
  }

  Future<void> signInAnonymously() async {
    final repository = ref.read(authRepositoryProvider);
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      await repository.signInAnonymously();
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'فشل الدخول كضيف. يرجى التأكد من تفعيل هذه الخاصية في Firebase.',
      );
    }
  }

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

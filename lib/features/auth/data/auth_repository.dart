import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository(this._auth);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    // For Web, reCAPTCHA is needed. Firebase handles this automatically if configured.
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInAnonymously() {
    return _auth.signInAnonymously();
  }

  Future<void> signOut() => _auth.signOut();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../auth/domain/user_model.dart';

final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authProvider);

  if (authState.user == null) {
    return null;
  }

  // Reload user role from Firestore
  final repository = ref.read(authRepositoryProvider);
  return await repository.getUserData(authState.user!.uid);
});

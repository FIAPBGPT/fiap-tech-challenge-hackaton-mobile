import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authProvider = Provider<User?>((ref) {
  final asyncUser = ref.watch(authStateProvider);
  return asyncUser.asData?.value;
});

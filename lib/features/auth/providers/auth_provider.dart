import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthStateProvider {
  static final authStateProvider = StreamProvider<User?>(
    (ref) => FirebaseAuth.instance.userChanges(),
  );
  static final currentUserProvider = Provider<User?>(
    (ref) => ref.watch(authStateProvider).value,
  );
}

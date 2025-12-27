import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/features/auth/providers/auth_provider.dart';
import 'package:mobile_classpal/features/main_view/screens/homepage_screen.dart';
import 'package:mobile_classpal/features/main_view/screens/welcome_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(AuthStateProvider.authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null)
          return const HomepageScreen();

        return const WelcomeScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, stack) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

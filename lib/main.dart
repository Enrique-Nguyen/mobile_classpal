import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/constants/fonts.dart';
import 'package:mobile_classpal/features/auth/screens/signin_screen.dart';
import 'package:mobile_classpal/features/auth/screens/signup_screen.dart';
import 'package:mobile_classpal/features/main_view/screens/homepage_screen.dart';
import 'package:mobile_classpal/features/main_view/screens/welcome_screen.dart';
import 'package:mobile_classpal/features/auth/widgets/auth_wrapper.dart';
import 'package:mobile_classpal/core/widgets/class_view_navigation.dart';
import 'package:mobile_classpal/core/models/class_view_arguments.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassPal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 77, 199, 162),
        ),
        textTheme: TextTheme(
          bodyLarge: Fonts.bodyLarge,
          bodyMedium: Fonts.bodyMedium,
          bodySmall: Fonts.bodySmall,

          titleLarge: Fonts.titleLarge,
          titleMedium: Fonts.titleMedium,
          titleSmall: Fonts.titleSmall,

          labelLarge: Fonts.labelLarge,
          labelMedium: Fonts.labelMedium,
          labelSmall: Fonts.labelSmall,

          displayLarge: Fonts.displayLarge,
          displayMedium: Fonts.displayMedium,
          displaySmall: Fonts.displaySmall,

          headlineLarge: Fonts.headlineLarge,
          headlineMedium: Fonts.headlineMedium,
          headlineSmall: Fonts.headlineSmall,
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F36),
            letterSpacing: -0.5,
          ),
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/signin': (context) => const SigninScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home_page': (context) => const HomepageScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/class') {
          final args = settings.arguments as ClassViewArguments;
          return MaterialPageRoute(
            builder: (context) => ClassViewNavigation(arguments: args),
          );
        }
        return null;
      },
    );
  }
}

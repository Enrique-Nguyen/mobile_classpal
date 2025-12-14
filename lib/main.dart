import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_classpal/features/auth/screens/signin_screen.dart';
import 'package:mobile_classpal/features/auth/screens/signup_screen.dart';
import 'package:mobile_classpal/features/main_view/screens/homepage.dart';
import 'features/main_view/screens/welcome.dart';
import 'core/widgets/class_view_navigation.dart';
import 'core/models/class_view_arguments.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
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
        textTheme: GoogleFonts.ptSansTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.ptSerif(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F36),
            letterSpacing: -0.5,
          ),
        ),
      ),
      home: const WelcomeScreen(),
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

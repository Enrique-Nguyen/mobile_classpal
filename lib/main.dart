import 'package:flutter/material.dart';
import 'features/main_view/screens/welcome.dart';
import 'core/widgets/class_view_navigation.dart';

void main() {
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
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
      routes: {'/class': (context) => const ClassViewNavigation()},
    );
  }
}

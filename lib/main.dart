import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Authentication/login_screen.dart';
import 'Firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          // Outline border settings
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.black),
          ),
          // Focused border settings
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.black, width: 2.0), // Color and width for focused border
          ),
          // Label style when unfocused
          labelStyle: const TextStyle(color: Colors.grey),
          // Label style when focused
          floatingLabelStyle: const TextStyle(color: Colors.black),
          // Hint text style
          hintStyle: const TextStyle(color: Colors.grey),
          // Prefix and suffix text style
          prefixStyle: const TextStyle(color: Colors.black),
          suffixStyle: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

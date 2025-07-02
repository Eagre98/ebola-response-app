import 'package:ebola_response_app/screens/auth/login_screen.dart';
import 'package:ebola_response_app/screens/auth/register_screen.dart';
import 'package:ebola_response_app/screens/public/chat_screen.dart';
import 'package:ebola_response_app/screens/public/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// --- Main Function: The starting point of the app ---
void main() async {
  // Ensure that all Flutter bindings are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for our project.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run our main application widget.
  runApp(const EbolaResponseApp());
}

// --- The Root Widget of the Application ---
class EbolaResponseApp extends StatelessWidget {
  const EbolaResponseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ebola Response App',
      // --- App Theme ---
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E), // Dark blue/purple
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C27B0), // Purple accent
          brightness: Brightness.dark,
          primary: const Color(0xFF9C27B0), // Main interactive color
          secondary: const Color(0xFFE040FB), // Lighter purple for accents
          background: const Color(0xFF1A1A2E), // Dark background
          surface: const Color(0xFF16213E), // Color for cards, dialogs
        ),
        useMaterial3: true,
      ),

      // --- App Navigation (Routing) ---
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}

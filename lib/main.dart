import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 1. MODIFIED main() function
void main() async {
  // Ensure that Flutter widgets are initialized before using async
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Calling the MyApp class here:
  runApp(const MyApp());
}

// ----------------------------------------------------
// 2. THE MISSING/MISPLACED CLASS DEFINITION
// ----------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Three 3D Track',
      theme: ThemeData(
        // You can keep your existing theme data here
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Replace the Placeholder with your actual starting widget (e.g., a Home or Wrapper screen)
      home: const Text('App Initialized!'),
    );
  }
}
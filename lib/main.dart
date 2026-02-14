import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'user_screen.dart';
import 'speak_type.dart';

// Global camera list
late List<CameraDescription> cameras;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Camera
  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const MaterialColor brandSwatch = MaterialColor(
    0xFFFFD400,
    <int, Color>{
      50: Color(0xFFFFF7E6),
      100: Color(0xFFFFEEC7),
      200: Color(0xFFFFE39A),
      300: Color(0xFFFFD86D),
      400: Color(0xFFFFCF47),
      500: Color(0xFFFFC700),
      600: Color(0xFFFFBF00),
      700: Color(0xFFFFB400),
      800: Color(0xFFFFAA00),
      900: Color(0xFFFF9900),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignRoute',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: brandSwatch,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/user': (context) => const UserScreen(),
      },
    );
  }
}

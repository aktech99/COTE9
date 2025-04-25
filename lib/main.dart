import 'package:cote/screens/teacher_shorts_upload.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/student_home.dart';
import 'screens/StudentDashboard.dart';
import 'screens/TeacherHome.dart';
import 'screens/subject_selection_screen.dart';
import 'screens/TeacherNotesPage.dart';
import 'screens/StudentNotesPage.dart';
import 'screens/StudentQuizPage.dart';
import 'screens/ExtractTextPage.dart';
import 'screens/profile_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/result_screen.dart';
import 'screens/leaderboards_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Manual setup
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COTE',
      theme: ThemeData(
        // Dark theme configuration
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        
        // Color Scheme
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
          background: Colors.black,
          surface: Colors.grey[900]!,
        ),
        
        // App Bar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        
        // Text Theme
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white.withOpacity(0.9)),
          bodyMedium: TextStyle(color: Colors.white.withOpacity(0.8)),
          titleLarge: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        
        // Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        
        // Material 3
        useMaterial3: true,
      ),
      
      // Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/StudentDashboard': (context) => const StudentDashboard(),
        '/student_home': (context) => const StudentHome(),
        '/StudentNotesPage': (context) => const StudentNotesPage(),
        '/StudentQuizPage': (context) => const StudentQuizPage(),
        '/TeacherHome': (context) => const TeacherHome(),
        '/TeacherNotesPage': (context) => const TeacherNotesPage(),
        '/subject_selection_screen': (context) => SubjectSelectionScreen(role: 'student'),
        '/ExtractTextPage': (context) => ExtractTextPage(url: ''),
        '/profile': (context) => const ProfileScreen(),
        '/bookmarks': (context) => const BookmarksScreen(),
        '/uploadShort': (context) => const TeacherShortsUpload(),
        '/leaderboard': (context) => const LeaderboardPage(),
      },
    );
  }
}
import 'package:cote/screens/teacher_shorts_upload.dart';
import 'package:cote/screens/teacherprofile_screen.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white.withOpacity(0.9)),
          bodyMedium: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Colors.deepPurple,
        ),
      ),
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
        '/teacherProfile': (context) => const TeacherProfileScreen(),
      },
    );
  }
}
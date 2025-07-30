import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/division_game_view.dart';

void main() {
  runApp(const MathDivisionGameApp());
}

class MathDivisionGameApp extends StatelessWidget {
  const MathDivisionGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Math Division Game - Interactive Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Modern, playful color scheme for educational games
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',

        // Vibrant and friendly aesthetic
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
        ),

        // Soft, rounded design elements
        cardTheme: CardTheme(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // High contrast colors for visibility
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.purple,
          ),
        ),
      ),
      home: const DivisionGameView(),
    );
  }
}

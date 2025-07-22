import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/division_game_view.dart';

void main() {
  runApp(const SynthesisTutorApp());
}

class SynthesisTutorApp extends StatelessWidget {
  const SynthesisTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Synthesis Tutor - Learn Division',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple, fontFamily: 'Roboto'),
      home: const DivisionGameView(),
    );
  }
}

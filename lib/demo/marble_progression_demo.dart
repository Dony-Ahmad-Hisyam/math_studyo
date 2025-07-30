import 'package:flutter/material.dart';
import '../widgets/marble_progression_widget.dart';

/// Demo app untuk menampilkan MarbleProgressionWidget
class MarbleProgressionDemo extends StatelessWidget {
  const MarbleProgressionDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marble Progression Demo',
      theme: ThemeData(primarySwatch: Colors.purple, fontFamily: 'Roboto'),
      home: const MarbleProgressionScreen(),
    );
  }
}

class MarbleProgressionScreen extends StatelessWidget {
  const MarbleProgressionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Marble Progression Visual'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: MarbleProgressionWidget(),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MarbleProgressionDemo());
}

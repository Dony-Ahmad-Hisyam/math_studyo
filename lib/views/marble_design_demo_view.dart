import 'package:flutter/material.dart';
import '../widgets/marble_transformation_widget.dart';
import '../widgets/enhanced_marble_widget.dart';

/// Demo screen untuk menampilkan marble transformation concept
class MarbleDesignDemoView extends StatefulWidget {
  const MarbleDesignDemoView({super.key});

  @override
  State<MarbleDesignDemoView> createState() => _MarbleDesignDemoViewState();
}

class _MarbleDesignDemoViewState extends State<MarbleDesignDemoView> {
  int selectedStage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text(
          'Educational Marble Design Concept',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade600, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                '🎯 Marble Transformation Concept\nModern, Playful Educational Design',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Transformation Widget
            const MarbleTransformationWidget(),

            const SizedBox(height: 32),

            // Interactive Marble Stages
            Text(
              '🎮 Interactive Marble Stages',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade800,
              ),
            ),
            const SizedBox(height: 16),

            // Stage Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 1; i <= 4; i++)
                  GestureDetector(
                    onTap: () => setState(() => selectedStage = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            selectedStage == i
                                ? Colors.purple
                                : Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purple, width: 2),
                      ),
                      child: Text(
                        'Stage $i',
                        style: TextStyle(
                          color:
                              selectedStage == i ? Colors.white : Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Selected Stage Display
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: EnhancedMarbleWidget(
                  size: 80,
                  stage: selectedStage,
                  isGlowing: true,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Stage Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                _getStageDescription(selectedStage),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade800,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // Educational Container Demo
            Text(
              '📦 Educational Container Example',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade800,
              ),
            ),
            const SizedBox(height: 16),

            EducationalMarbleContainer(
              label: '7 Orange Marbles - Division Example',
              containerColor: Colors.orange,
              marbles: List.generate(7, (index) {
                return EnhancedMarbleWidget(
                  size: 32,
                  stage: 1,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Marble ${index + 1} tapped!'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 24),

            // Design Principles
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎨 Design Principles Applied',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    '✨ Flat vector illustration style',
                    '🌈 High contrast, vibrant colors',
                    '📱 Mobile-friendly UI design',
                    '🎯 Minimal shadows, maximum clarity',
                    '😊 Friendly and playful aesthetic',
                    '🔄 Progressive transformation stages',
                    '💎 Soft glow and gradient edges',
                  ].map(
                    (principle) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        principle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getStageDescription(int stage) {
    switch (stage) {
      case 1:
        return '🔵 Stage 1: Simple Blue Sphere\nBasic marble with radial gradient and 3D highlight effect';
      case 2:
        return '🟣 Stage 2: Connected Purple Spheres\nTwo marbles joined together, representing addition or pairing';
      case 3:
        return '🌸 Stage 3: Purple-Pink Clover\nThree connected spheres in clover formation, showing grouping concepts';
      case 4:
        return '⭐ Stage 4: Red Star with Diamond Glow\nFour-lobed star marble with central diamond glow, representing mastery';
      default:
        return '';
    }
  }
}

/// Widget untuk mendemonstrasikan penggunaan dalam game
class GameIntegrationExample extends StatelessWidget {
  const GameIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎮 Game Integration Example',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade800,
            ),
          ),
          const SizedBox(height: 16),

          // Row of different stage marbles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 1; i <= 4; i++)
                Column(
                  children: [
                    EnhancedMarbleWidget(
                      size: 50,
                      stage: i,
                      isGlowing: i == 4, // Only stage 4 glows
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lv.$i',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade600,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Educational note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow.shade300),
            ),
            child: Text(
              '💡 Educational Note: Each marble stage represents increasing complexity in mathematical understanding, from simple counting to advanced grouping concepts.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.yellow.shade800,
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'enhanced_marble_widget.dart';

/// Widget untuk menampilkan transformasi marble dalam tahapan pembelajaran
class MarbleTransformationWidget extends StatelessWidget {
  const MarbleTransformationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Title
          Text(
            'Marble Transformation Stages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade800,
            ),
          ),
          const SizedBox(height: 16),

          // Transformation stages
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              EnhancedMarbleWidget(size: 40, stage: 1), // Blue sphere
              _buildArrow(),
              EnhancedMarbleWidget(size: 40, stage: 2), // Two purple connected
              _buildArrow(),
              EnhancedMarbleWidget(size: 40, stage: 3), // Three pink clover
              _buildArrow(),
              EnhancedMarbleWidget(
                size: 40,
                stage: 4,
                isGlowing: true,
              ), // Red star with diamond
            ],
          ),

          const SizedBox(height: 24),

          // Container with aligned marbles
          _buildMarbleContainer(),
        ],
      ),
    );
  }

  /// Arrow between stages
  Widget _buildArrow() {
    return Icon(
      Icons.arrow_forward_ios,
      color: Colors.purple.shade600,
      size: 16,
    );
  }

  /// Container with 7 aligned orange marbles
  Widget _buildMarbleContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(7, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index < 6 ? 8 : 0),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.orange.shade300,
                    Colors.orange.shade600,
                    Colors.orange.shade800,
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

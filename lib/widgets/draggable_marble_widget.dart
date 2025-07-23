import 'package:flutter/material.dart';
import '../data/models/game_models.dart';

/// Widget untuk marble yang bisa di-drag
class DraggableMarbleWidget extends StatelessWidget {
  final Marble marble;
  final bool isDragging;
  final double opacity;

  const DraggableMarbleWidget({
    super.key,
    required this.marble,
    this.isDragging = false,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3), // Offset untuk efek 3D
            colors: _getMarbleColors(),
            stops: const [0.0, 0.4, 0.8, 1.0],
          ),
          border:
              isDragging
                  ? Border.all(color: Colors.white, width: 2)
                  : marble.isInGroup
                  ? Border.all(color: Colors.greenAccent, width: 2)
                  : null,
          boxShadow: [
            // Shadow utama untuk efek 3D yang lebih dalam
            BoxShadow(
              color: Colors.black.withOpacity(isDragging ? 0.5 : 0.35),
              blurRadius: isDragging ? 20 : 12,
              offset: Offset(0, isDragging ? 10 : 6),
              spreadRadius: isDragging ? 4 : 2,
            ),
            // Inner shadow untuk depth
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
            // Highlight untuk efek glossy
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(-3, -3),
              spreadRadius: -2,
            ),
          ],
        ),
        child:
            marble.isInGroup
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
      ),
    );
  }

  /// Get marble colors based on group
  List<Color> _getMarbleColors() {
    if (marble.isInGroup) {
      switch (marble.groupIndex) {
        case 0: // Orange group
          return [
            const Color(0xFFFFE4B5), // Very light orange highlight
            const Color(0xFFFFCC80), // Light orange
            const Color(0xFFFF9800), // Orange
            const Color(0xFFE65100), // Dark orange
          ];
        case 1: // Yellow group
          return [
            const Color(0xFFFFFDE7), // Very light yellow highlight
            const Color(0xFFFFF9C4), // Light yellow
            const Color(0xFFFFEB3B), // Yellow
            const Color(0xFFF57F17), // Dark yellow
          ];
        case 2: // Light Blue group
          return [
            const Color(0xFFE1F5FE), // Very light blue highlight
            const Color(0xFF81D4FA), // Light blue
            const Color(0xFF03A9F4), // Blue
            const Color(0xFF0277BD), // Dark blue
          ];
        default:
          return [
            const Color(0xFFE1BEE7), // Very light purple highlight
            const Color(0xFFB388FF), // Default light purple
            const Color(0xFF7B1FA2), // Default purple
            const Color(0xFF4A148C), // Default dark purple
          ];
      }
    } else {
      return [
        const Color(0xFFE1BEE7), // Very light purple highlight
        const Color(0xFFB388FF), // Default light purple
        const Color(0xFF7B1FA2), // Default purple
        const Color(0xFF4A148C), // Default dark purple
      ];
    }
  }
}

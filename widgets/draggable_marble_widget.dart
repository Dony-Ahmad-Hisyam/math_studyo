import 'package:flutter/material.dart';
import '../models/game_models.dart';

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

  /// Get gradient color based on number of connected marbles
  RadialGradient _getMarbleGradient(Marble marble) {
    // Get the number of connected marbles in the group
    int connectionCount = marble.getConnectionGroup().length;

    // Change color based on number of connected marbles
    switch (connectionCount) {
      case 1:
        // Single marble - blue (Bola 1 in reference image)
        return const RadialGradient(
          colors: [
            Color(0xFF8CBAFF), // Light blue
            Color(0xFF2196F3), // Mid blue
            Color(0xFF0D47A1), // Dark blue
          ],
          stops: [0.0, 0.7, 1.0],
        );
      case 2:
        // Two marbles - purple (Bola 2 in reference image)
        return const RadialGradient(
          colors: [
            Color(0xFFD1A1FF), // Light purple
            Color(0xFF9C27B0), // Mid purple
            Color(0xFF6A1B9A), // Dark purple
          ],
          stops: [0.0, 0.7, 1.0],
        );
      case 3:
        // Three marbles - pink/red (Bola 3 in reference image)
        return const RadialGradient(
          colors: [
            Color(0xFFFFA1C1), // Light pink
            Color(0xFFE91E63), // Mid pink/red
            Color(0xFFB71C1C), // Dark red
          ],
          stops: [0.0, 0.7, 1.0],
        );
      case 4:
        // Four marbles - red/orange with yellow center (Bola 4 in reference image)
        return const RadialGradient(
          colors: [
            Color(0xFFFFEB3B), // Yellow center
            Color(0xFFF44336), // Red
            Color(0xFFBF360C), // Dark orange/red
          ],
          stops: [0.0, 0.5, 1.0],
        );
      default:
        // More marbles or fallback - purple gradient (original)
        return const RadialGradient(
          colors: [
            Color(0xFFB388FF), // Lighter purple
            Color(0xFF7B1FA2), // Main purple
            Color(0xFF4A148C), // Darker purple
          ],
          stops: [0.0, 0.7, 1.0],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _getMarbleGradient(marble),
          border:
              isDragging
                  ? Border.all(color: Colors.white, width: 2)
                  : marble.isInGroup
                  ? Border.all(color: Colors.greenAccent, width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDragging ? 0.4 : 0.22),
              blurRadius: isDragging ? 16 : 8,
              offset: Offset(0, isDragging ? 8 : 4),
              spreadRadius: isDragging ? 3 : 1,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(-2, -2),
              spreadRadius: -1,
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
}

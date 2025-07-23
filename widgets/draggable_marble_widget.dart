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
            colors: [
              const Color(0xFFB388FF), // Lighter purple
              const Color(0xFF7B1FA2), // Main purple
              const Color(0xFF4A148C), // Darker purple
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
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

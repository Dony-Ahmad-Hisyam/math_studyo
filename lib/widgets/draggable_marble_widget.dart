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
            center: const Alignment(
              -0.4,
              -0.4,
            ), // Highlight position seperti YouTube
            colors: _getMarbleColors(),
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
          border:
              isDragging
                  ? Border.all(color: Colors.white.withOpacity(0.8), width: 2)
                  : marble.connectedMarbles.isNotEmpty && !marble.isInGroup
                  ? Border.all(color: Colors.white.withOpacity(0.6), width: 1.5)
                  : marble.isInGroup
                  ? Border.all(color: Colors.greenAccent, width: 2)
                  : null,
          boxShadow: [
            // Main shadow untuk depth seperti YouTube
            BoxShadow(
              color: Colors.black.withOpacity(isDragging ? 0.4 : 0.25),
              blurRadius: isDragging ? 16 : 8,
              offset: Offset(2, isDragging ? 8 : 4),
              spreadRadius: isDragging ? 2 : 0,
            ),
            // Soft glow untuk marble yang terhubung
            if (marble.connectedMarbles.isNotEmpty && !marble.isInGroup)
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 0),
                spreadRadius: 2,
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

  /// Get marble colors - deep red seperti di YouTube
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
        case 2: // Green group (bukan blue)
          return [
            const Color(0xFFE8F5E8), // Very light green highlight
            const Color(0xFFA5D6A7), // Light green
            const Color(0xFF4CAF50), // Green
            const Color(0xFF2E7D32), // Dark green
          ];
        default:
          return [
            const Color(0xFFFFCDD2), // Light red highlight seperti YouTube
            const Color(0xFFEF5350), // Medium red
            const Color(0xFFD32F2F), // Deep red
            const Color(0xFFB71C1C), // Very deep red
          ];
      }
    } else {
      // Warna sesuai dengan jumlah marbles yang terhubung, mengikuti gambar referensi
      int connectedCount =
          marble.connectedMarbles.length + 1; // +1 untuk diri sendiri

      if (connectedCount == 1) {
        // Bola 1: Biru
        return [
          const Color(0xFFBBDEFB), // Light blue highlight
          const Color(0xFF64B5F6), // Medium blue
          const Color(0xFF2196F3), // Blue
          const Color(0xFF1565C0), // Dark blue
        ];
      } else if (connectedCount == 2) {
        // Bola 2: Ungu
        return [
          const Color(0xFFE1BEE7), // Light purple highlight
          const Color(0xFFBA68C8), // Medium purple
          const Color(0xFF9C27B0), // Purple
          const Color(0xFF6A1B9A), // Dark purple
        ];
      } else if (connectedCount == 3) {
        // Bola 3: Pink kemerahan
        return [
          const Color(0xFFF8BBD0), // Light pink highlight
          const Color(0xFFF06292), // Medium pink
          const Color(0xFFE91E63), // Pink
          const Color(0xFFC2185B), // Dark pink
        ];
      } else if (connectedCount >= 4) {
        // Bola 4+: Merah
        return [
          const Color(0xFFFFCDD2), // Light red highlight
          const Color(0xFFE57373), // Medium red
          const Color(0xFFE53935), // Red
          const Color(0xFFB71C1C), // Dark red
        ];
      } else {
        // Default: Biru
        return [
          const Color(0xFFBBDEFB), // Light blue highlight
          const Color(0xFF64B5F6), // Medium blue
          const Color(0xFF2196F3), // Blue
          const Color(0xFF1565C0), // Dark blue
        ];
      }
    }
  }
}

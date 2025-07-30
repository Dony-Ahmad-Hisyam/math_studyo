import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget untuk menampilkan progression marble dalam layout vertikal
class MarbleProgressionWidget extends StatelessWidget {
  const MarbleProgressionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Marble Transformation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          _buildStage('Bola 1', 1),
          const SizedBox(height: 20),
          _buildStage('Bola 2', 2),
          const SizedBox(height: 20),
          _buildStage('Bola 3', 3),
          const SizedBox(height: 20),
          _buildStage('Bola 4', 4),
          const SizedBox(height: 20),
          _buildStage('DST', 0), // 0 untuk dots indicator
        ],
      ),
    );
  }

  /// Build individual stage dengan label dan marble
  Widget _buildStage(String label, int stage) {
    return Row(
      children: [
        // Label di kiri
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Marble visual di tengah
        Expanded(
          child: Center(
            child: SizedBox(
              height: 60,
              child:
                  stage == 0
                      ? _buildDotsIndicator()
                      : CustomPaint(
                        painter: MarbleStageCustomPainter(stage),
                        size: const Size(120, 60),
                      ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build dots indicator untuk "DST"
  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

/// Custom painter untuk menggambar marble stages
class MarbleStageCustomPainter extends CustomPainter {
  final int stage;

  MarbleStageCustomPainter(this.stage);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (stage) {
      case 1:
        _paintStage1(canvas, center);
        break;
      case 2:
        _paintStage2(canvas, center);
        break;
      case 3:
        _paintStage3(canvas, center);
        break;
      case 4:
        _paintStage4(canvas, center);
        break;
    }
  }

  /// Stage 1: Single solid blue sphere dengan glow
  void _paintStage1(Canvas canvas, Offset center) {
    const radius = 22.0;

    // Soft glow effect yang lebih besar
    final glowPaint =
        Paint()
          ..color = const Color(0xFF3498DB).withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(center, radius + 12, glowPaint);

    // Main sphere dengan gradient yang lebih smooth
    final paint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.2, -0.2),
            colors: [
              const Color(0xFFAED6F1), // Very light blue highlight
              const Color(0xFF5DADE2), // Light blue
              const Color(0xFF3498DB), // Medium blue
              const Color(0xFF2874A6), // Dark blue edge
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);

    // Multiple inner highlights untuk efek glossy
    final highlight1 = Paint()..color = Colors.white.withOpacity(0.7);
    canvas.drawCircle(center + const Offset(-8, -8), 5, highlight1);

    final highlight2 = Paint()..color = Colors.white.withOpacity(0.4);
    canvas.drawCircle(center + const Offset(-6, -6), 8, highlight2);
  }

  /// Stage 2: Two purple spheres organically merged (peanut/dumbbell shape)
  void _paintStage2(Canvas canvas, Offset center) {
    const radius = 18.0;
    const spacing = 20.0; // Closer spacing for better merge effect

    final leftCenter = Offset(center.dx - spacing, center.dy);
    final rightCenter = Offset(center.dx + spacing, center.dy);

    // Create organic connection using bezier curves
    final connectionPath = Path();

    // Start from top of left sphere
    connectionPath.moveTo(leftCenter.dx, leftCenter.dy - radius);

    // Curve to right sphere top
    connectionPath.quadraticBezierTo(
      center.dx,
      center.dy - radius * 0.7, // Control point
      rightCenter.dx,
      rightCenter.dy - radius,
    );

    // Right sphere outline
    connectionPath.arcTo(
      Rect.fromCircle(center: rightCenter, radius: radius),
      -math.pi / 2, // Start angle
      math.pi, // Sweep angle
      false,
    );

    // Bottom connection curve
    connectionPath.quadraticBezierTo(
      center.dx,
      center.dy + radius * 0.7, // Control point
      leftCenter.dx,
      leftCenter.dy + radius,
    );

    // Left sphere outline
    connectionPath.arcTo(
      Rect.fromCircle(center: leftCenter, radius: radius),
      math.pi / 2, // Start angle
      math.pi, // Sweep angle
      false,
    );

    connectionPath.close();

    // Paint merged shape dengan gradient
    final mergePaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFFBB8FCE), // Light purple
              const Color(0xFF9B59B6), // Medium purple
              const Color(0xFF7D3C98), // Dark purple
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromLTWH(
              leftCenter.dx - radius,
              center.dy - radius,
              spacing * 2 + radius * 2,
              radius * 2,
            ),
          );

    canvas.drawPath(connectionPath, mergePaint);

    // Connection highlight line
    final connectionLinePaint =
        Paint()
          ..color = const Color(0xFFD7BDE2).withOpacity(0.8)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(leftCenter, rightCenter, connectionLinePaint);

    // Individual sphere highlights
    final highlight = Paint()..color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(leftCenter + const Offset(-5, -5), 4, highlight);
    canvas.drawCircle(rightCenter + const Offset(-5, -5), 4, highlight);
  }

  /// Stage 3: Three bright pink marbles in organic clover formation
  void _paintStage3(Canvas canvas, Offset center) {
    const radius = 16.0;
    const distance = 18.0; // Closer for better merge

    final positions = [
      Offset(center.dx, center.dy - distance), // Top
      Offset(
        center.dx - distance * 0.866,
        center.dy + distance * 0.5,
      ), // Bottom left
      Offset(
        center.dx + distance * 0.866,
        center.dy + distance * 0.5,
      ), // Bottom right
    ];

    // Create organic clover shape using paths
    var cloverPath = Path();

    // Start with central merger area
    final centralRadius = radius * 0.6;
    cloverPath.addOval(Rect.fromCircle(center: center, radius: centralRadius));

    // Add each petal as part of unified shape
    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];

      // Create petal path that connects to center
      final petalPath = Path();
      petalPath.addOval(Rect.fromCircle(center: pos, radius: radius));

      // Merge with main path
      cloverPath = Path.combine(PathOperation.union, cloverPath, petalPath);
    }

    // Paint unified clover shape
    final cloverPaint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, 0),
            colors: [
              const Color(0xFFF8BBD9), // Very light pink
              const Color(0xFFE91E63), // Bright pink
              const Color(0xFFC2185B), // Medium pink
              const Color(0xFF880E4F), // Dark pink edge
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ).createShader(
            Rect.fromCircle(center: center, radius: distance + radius),
          );

    canvas.drawPath(cloverPath, cloverPaint);

    // Connection lines forming flower pattern
    final connectionPaint =
        Paint()
          ..color = const Color(0xFFFCE4EC).withOpacity(0.9)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    // Draw lines from center to each position
    for (var pos in positions) {
      canvas.drawLine(center, pos, connectionPaint);
    }

    // Central highlight
    final centralHighlight = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(center, 4, centralHighlight);

    // Individual petal highlights
    final petalHighlight = Paint()..color = Colors.white.withOpacity(0.6);
    for (var pos in positions) {
      canvas.drawCircle(pos + const Offset(-4, -4), 3, petalHighlight);
    }
  }

  /// Stage 4: Four red marbles in symmetrical cross/flower with glowing center
  void _paintStage4(Canvas canvas, Offset center) {
    const radius = 15.0;
    const distance = 22.0;

    final positions = [
      Offset(center.dx, center.dy - distance), // Top
      Offset(center.dx + distance, center.dy), // Right
      Offset(center.dx, center.dy + distance), // Bottom
      Offset(center.dx - distance, center.dy), // Left
    ];

    // Create unified flower shape
    var flowerPath = Path();

    // Central core
    final centralRadius = radius * 0.8;
    flowerPath.addOval(Rect.fromCircle(center: center, radius: centralRadius));

    // Add each petal with organic connection
    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];

      // Create petal
      final petalPath = Path();
      petalPath.addOval(Rect.fromCircle(center: pos, radius: radius));

      // Create connecting bridge
      final bridgePath = Path();
      final angle = math.atan2(pos.dy - center.dy, pos.dx - center.dx);
      final bridgeWidth = radius * 0.6;

      bridgePath.moveTo(
        center.dx + math.cos(angle + math.pi / 2) * bridgeWidth / 2,
        center.dy + math.sin(angle + math.pi / 2) * bridgeWidth / 2,
      );
      bridgePath.lineTo(
        pos.dx -
            math.cos(angle) * radius / 2 +
            math.cos(angle + math.pi / 2) * bridgeWidth / 2,
        pos.dy -
            math.sin(angle) * radius / 2 +
            math.sin(angle + math.pi / 2) * bridgeWidth / 2,
      );
      bridgePath.lineTo(
        pos.dx -
            math.cos(angle) * radius / 2 +
            math.cos(angle - math.pi / 2) * bridgeWidth / 2,
        pos.dy -
            math.sin(angle) * radius / 2 +
            math.sin(angle - math.pi / 2) * bridgeWidth / 2,
      );
      bridgePath.lineTo(
        center.dx + math.cos(angle - math.pi / 2) * bridgeWidth / 2,
        center.dy + math.sin(angle - math.pi / 2) * bridgeWidth / 2,
      );
      bridgePath.close();

      // Union all parts
      flowerPath = Path.combine(PathOperation.union, flowerPath, petalPath);
      flowerPath = Path.combine(PathOperation.union, flowerPath, bridgePath);
    }

    // Paint unified flower
    final flowerPaint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, 0),
            colors: [
              const Color(0xFFFFCDD2), // Very light red
              const Color(0xFFE57373), // Light red
              const Color(0xFFF44336), // Medium red
              const Color(0xFFD32F2F), // Dark red
              const Color(0xFFB71C1C), // Very dark red edge
            ],
            stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
          ).createShader(
            Rect.fromCircle(center: center, radius: distance + radius),
          );

    canvas.drawPath(flowerPath, flowerPaint);

    // Star pattern connection lines
    final starPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    // X pattern lines
    canvas.drawLine(positions[0], positions[2], starPaint); // Top to bottom
    canvas.drawLine(positions[1], positions[3], starPaint); // Right to left

    // Plus pattern lines
    final plusPaint =
        Paint()
          ..color = const Color(0xFFFFEBEE).withOpacity(0.8)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

    for (var pos in positions) {
      canvas.drawLine(center, pos, plusPaint);
    }

    // Central glowing diamond
    _drawGlowingDiamond(canvas, center);

    // Petal highlights
    final petalHighlight = Paint()..color = Colors.white.withOpacity(0.6);
    for (var pos in positions) {
      canvas.drawCircle(pos + const Offset(-4, -4), 3, petalHighlight);
    }
  }

  /// Helper: Draw glowing diamond in center
  void _drawGlowingDiamond(Canvas canvas, Offset center) {
    // Glow effect
    final glowPaint =
        Paint()
          ..color = Colors.yellow.withOpacity(0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(center, 12, glowPaint);

    // Diamond shape
    final diamondPath = Path();
    const size = 8.0;

    diamondPath.moveTo(center.dx, center.dy - size); // Top
    diamondPath.lineTo(center.dx + size, center.dy); // Right
    diamondPath.lineTo(center.dx, center.dy + size); // Bottom
    diamondPath.lineTo(center.dx - size, center.dy); // Left
    diamondPath.close();

    final diamondPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFF59D), // Light yellow
              const Color(0xFFFFD54F), // Medium gold
              const Color(0xFFFF8F00), // Dark gold
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: size));

    canvas.drawPath(diamondPath, diamondPaint);

    // Diamond outline
    final outlinePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    canvas.drawPath(diamondPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

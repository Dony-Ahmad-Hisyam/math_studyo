import 'package:flutter/material.dart';
import 'dart:math';

/// Demo widget showing marble clustering design with glowing connection lines
class MarbleClusterDemoWidget extends StatelessWidget {
  const MarbleClusterDemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Interactive Marble Clusters'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.purple,
      ),
      body: const Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Magnetic Marble Grouping System',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Deep red marbles with magnetic connections',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 40),
              MarbleClusterCanvas(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom widget that draws marble clusters with glowing connection lines
class MarbleClusterCanvas extends StatelessWidget {
  const MarbleClusterCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: MarbleClusterPainter(),
        size: const Size(350, 250),
      ),
    );
  }
}

/// Custom painter for drawing marble clusters with connection lines
class MarbleClusterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define marble clusters positions
    final clusters = [
      // Cluster 1 - Top left
      ClusterData(
        center: Offset(size.width * 0.25, size.height * 0.35),
        marbles: 4,
      ),
      // Cluster 2 - Top right
      ClusterData(
        center: Offset(size.width * 0.75, size.height * 0.35),
        marbles: 4,
      ),
      // Cluster 3 - Bottom center
      ClusterData(
        center: Offset(size.width * 0.5, size.height * 0.75),
        marbles: 4,
      ),
    ];

    // Draw each cluster
    for (var cluster in clusters) {
      _drawMarbleCluster(canvas, cluster);
    }
  }

  void _drawMarbleCluster(Canvas canvas, ClusterData cluster) {
    const double marbleRadius = 16.0;
    const double clusterRadius = 18.0; // Distance from center to marble centers

    // Calculate marble positions in clover/flower formation
    List<Offset> marblePositions = [];
    for (int i = 0; i < cluster.marbles; i++) {
      double angle = (i * 2 * pi) / cluster.marbles;
      Offset marblePos = Offset(
        cluster.center.dx + cos(angle) * clusterRadius,
        cluster.center.dy + sin(angle) * clusterRadius,
      );
      marblePositions.add(marblePos);
    }

    // Draw glowing connection lines first (behind marbles)
    _drawConnectionLines(canvas, marblePositions, cluster.center);

    // Draw marbles with shadows and glossy texture
    for (var position in marblePositions) {
      _drawMarble(canvas, position, marbleRadius);
    }

    // Draw center glow
    _drawCenterGlow(canvas, cluster.center);
  }

  void _drawConnectionLines(
    Canvas canvas,
    List<Offset> marblePositions,
    Offset center,
  ) {
    // Paint for glowing connection lines
    final glowPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final linePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    // Draw lines connecting adjacent marbles
    for (int i = 0; i < marblePositions.length; i++) {
      int nextIndex = (i + 1) % marblePositions.length;

      // Draw glow effect
      canvas.drawLine(
        marblePositions[i],
        marblePositions[nextIndex],
        glowPaint,
      );
      // Draw actual line
      canvas.drawLine(
        marblePositions[i],
        marblePositions[nextIndex],
        linePaint,
      );
    }

    // Draw lines from center to each marble for triangle/web effect
    for (var position in marblePositions) {
      canvas.drawLine(center, position, glowPaint);
      canvas.drawLine(center, position, linePaint);
    }
  }

  void _drawMarble(Canvas canvas, Offset position, double radius) {
    // Shadow
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawCircle(
      Offset(position.dx + 2, position.dy + 2),
      radius,
      shadowPaint,
    );

    // Base marble - deep red
    final basePaint =
        Paint()
          ..color = const Color(0xFFB71C1C) // Deep red
          ..style = PaintingStyle.fill;

    canvas.drawCircle(position, radius, basePaint);

    // Glossy highlight
    final highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(position.dx - 4, position.dy - 4),
      radius * 0.4,
      highlightPaint,
    );

    // Subtle rim light
    final rimPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    canvas.drawCircle(position, radius - 1, rimPaint);

    // Magnetic glow effect around marble
    final magneticGlowPaint =
        Paint()
          ..color = Colors.red.withOpacity(0.1)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    canvas.drawCircle(position, radius + 4, magneticGlowPaint);
  }

  void _drawCenterGlow(Canvas canvas, Offset center) {
    // Central glow effect
    final centerGlowPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    canvas.drawCircle(center, 8.0, centerGlowPaint);

    // Bright center point
    final centerPointPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 3.0, centerPointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Data class for cluster information
class ClusterData {
  final Offset center;
  final int marbles;

  ClusterData({required this.center, required this.marbles});
}

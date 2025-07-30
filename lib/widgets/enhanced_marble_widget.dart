import 'package:flutter/material.dart';

/// Enhanced marble widget dengan transformation stages dan modern design
class EnhancedMarbleWidget extends StatefulWidget {
  final double size;
  final int stage; // 1-4 for transformation stages
  final bool isGlowing;
  final VoidCallback? onTap;

  const EnhancedMarbleWidget({
    super.key,
    this.size = 32,
    this.stage = 1,
    this.isGlowing = false,
    this.onTap,
  });

  @override
  State<EnhancedMarbleWidget> createState() => _EnhancedMarbleWidgetState();
}

class _EnhancedMarbleWidgetState extends State<EnhancedMarbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isGlowing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: MarbleStagePainter(
                stage: widget.stage,
                glowIntensity: widget.isGlowing ? _glowAnimation.value : 0.0,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter untuk marble dengan berbagai transformation stages
class MarbleStagePainter extends CustomPainter {
  final int stage;
  final double glowIntensity;

  MarbleStagePainter({required this.stage, required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    switch (stage) {
      case 1:
        _paintStage1(canvas, center, radius); // Simple blue sphere
        break;
      case 2:
        _paintStage2(canvas, center, radius); // Two connected purple spheres
        break;
      case 3:
        _paintStage3(canvas, center, radius); // Three purple-pink clover
        break;
      case 4:
        _paintStage4(canvas, center, radius); // Four-lobed red star
        break;
      default:
        _paintStage1(canvas, center, radius);
    }

    // Add glow effect if needed
    if (glowIntensity > 0) {
      _paintGlowEffect(canvas, center, radius);
    }
  }

  /// Stage 1: Bola biru solid seperti gambar
  void _paintStage1(Canvas canvas, Offset center, double radius) {
    final paint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [
              const Color(0xFF5DADE2), // Light blue highlight
              const Color(0xFF3498DB), // Medium blue
              const Color(0xFF2874A6), // Dark blue edge
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.9, paint);
  }

  /// Stage 2: Dua bola ungu yang overlap dengan garis penghubung
  void _paintStage2(Canvas canvas, Offset center, double radius) {
    final ballRadius = radius * 0.6;
    final leftCenter = Offset(center.dx - ballRadius * 0.6, center.dy);
    final rightCenter = Offset(center.dx + ballRadius * 0.6, center.dy);

    // Gambar garis penghubung dulu (di belakang)
    final linePaint =
        Paint()
          ..color = const Color(0xFF8E44AD).withOpacity(0.8)
          ..strokeWidth = ballRadius * 0.4
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(leftCenter, rightCenter, linePaint);

    // Bola kiri
    final leftPaint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [
              const Color(0xFFBB8FCE), // Light purple highlight
              const Color(0xFF9B59B6), // Medium purple
              const Color(0xFF7D3C98), // Dark purple edge
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(
            Rect.fromCircle(center: leftCenter, radius: ballRadius),
          );

    canvas.drawCircle(leftCenter, ballRadius, leftPaint);

    // Bola kanan
    final rightPaint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [
              const Color(0xFFBB8FCE), // Light purple highlight
              const Color(0xFF9B59B6), // Medium purple
              const Color(0xFF7D3C98), // Dark purple edge
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(
            Rect.fromCircle(center: rightCenter, radius: ballRadius),
          );

    canvas.drawCircle(rightCenter, ballRadius, rightPaint);
  }

  /// Stage 3: Tiga bola pink-ungu dalam formasi segitiga dengan garis
  void _paintStage3(Canvas canvas, Offset center, double radius) {
    final ballRadius = radius * 0.5;
    final positions = [
      Offset(center.dx, center.dy - radius * 0.5), // Top
      Offset(
        center.dx - radius * 0.43,
        center.dy + radius * 0.25,
      ), // Bottom left
      Offset(
        center.dx + radius * 0.43,
        center.dy + radius * 0.25,
      ), // Bottom right
    ];

    // Gambar garis penghubung antar bola
    final linePaint =
        Paint()
          ..color = const Color(0xFFAD5AAD).withOpacity(0.7)
          ..strokeWidth = ballRadius * 0.3
          ..strokeCap = StrokeCap.round;

    // Garis dari atas ke kiri bawah
    canvas.drawLine(positions[0], positions[1], linePaint);
    // Garis dari atas ke kanan bawah
    canvas.drawLine(positions[0], positions[2], linePaint);
    // Garis dari kiri bawah ke kanan bawah
    canvas.drawLine(positions[1], positions[2], linePaint);

    // Gambar tiga bola
    for (int i = 0; i < positions.length; i++) {
      final paint =
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.3),
              colors: [
                const Color(0xFFE8B4E8), // Light pink highlight
                const Color(0xFFD567D5), // Medium pink-purple
                const Color(0xFFAD5AAD), // Dark pink-purple edge
              ],
              stops: const [0.0, 0.6, 1.0],
            ).createShader(
              Rect.fromCircle(center: positions[i], radius: ballRadius),
            );

      canvas.drawCircle(positions[i], ballRadius, paint);
    }
  }

  /// Stage 4: Empat bola merah dalam formasi bunga dengan bintang diamond di tengah
  void _paintStage4(Canvas canvas, Offset center, double radius) {
    final ballRadius = radius * 0.45;
    final positions = [
      Offset(center.dx, center.dy - radius * 0.6), // Top
      Offset(center.dx + radius * 0.6, center.dy), // Right
      Offset(center.dx, center.dy + radius * 0.6), // Bottom
      Offset(center.dx - radius * 0.6, center.dy), // Left
    ];

    // Gambar garis penghubung dari tengah ke setiap bola
    final linePaint =
        Paint()
          ..color = const Color(0xFFE74C3C).withOpacity(0.8)
          ..strokeWidth = ballRadius * 0.25
          ..strokeCap = StrokeCap.round;

    for (final position in positions) {
      canvas.drawLine(center, position, linePaint);
    }

    // Gambar empat bola merah
    for (final position in positions) {
      final paint =
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.3),
              colors: [
                const Color(0xFFF1948A), // Light red highlight
                const Color(0xFFE74C3C), // Medium red
                const Color(0xFFCB4335), // Dark red edge
              ],
              stops: const [0.0, 0.6, 1.0],
            ).createShader(
              Rect.fromCircle(center: position, radius: ballRadius),
            );

      canvas.drawCircle(position, ballRadius, paint);
    }

    // Gambar bintang diamond di tengah
    _paintDiamondStar(canvas, center, radius * 0.3);
  }

  /// Gambar bintang diamond di tengah untuk stage 4
  void _paintDiamondStar(Canvas canvas, Offset center, double size) {
    final path = Path();
    final starSize = size * 0.8;

    // Buat bentuk bintang dengan 4 titik
    final points = <Offset>[
      Offset(center.dx, center.dy - starSize), // Top
      Offset(
        center.dx + starSize * 0.3,
        center.dy - starSize * 0.3,
      ), // Top right
      Offset(center.dx + starSize, center.dy), // Right
      Offset(
        center.dx + starSize * 0.3,
        center.dy + starSize * 0.3,
      ), // Bottom right
      Offset(center.dx, center.dy + starSize), // Bottom
      Offset(
        center.dx - starSize * 0.3,
        center.dy + starSize * 0.3,
      ), // Bottom left
      Offset(center.dx - starSize, center.dy), // Left
      Offset(
        center.dx - starSize * 0.3,
        center.dy - starSize * 0.3,
      ), // Top left
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    // Fill bintang dengan gradient emas
    final starPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFF59D), // Light yellow gold
              const Color(0xFFFFD54F), // Medium gold
              const Color(0xFFFF8F00), // Dark gold
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: starSize));

    canvas.drawPath(path, starPaint);

    // Outline bintang
    final outlinePaint =
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    canvas.drawPath(path, outlinePaint);
  }

  /// Add glow effect
  void _paintGlowEffect(Canvas canvas, Offset center, double radius) {
    final glowPaint =
        Paint()
          ..color = Colors.yellow.withOpacity(0.3 * glowIntensity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * glowIntensity);

    canvas.drawCircle(center, radius * (1.2 + 0.3 * glowIntensity), glowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is MarbleStagePainter &&
        (oldDelegate.stage != stage ||
            oldDelegate.glowIntensity != glowIntensity);
  }
}

/// Educational marble container widget
class EducationalMarbleContainer extends StatelessWidget {
  final List<Widget> marbles;
  final Color containerColor;
  final String label;

  const EducationalMarbleContainer({
    super.key,
    required this.marbles,
    this.containerColor = Colors.purple,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: containerColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: containerColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: containerColor,
                fontSize: 16,
              ),
            ),
          if (label.isNotEmpty) const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: marbles),
        ],
      ),
    );
  }
}

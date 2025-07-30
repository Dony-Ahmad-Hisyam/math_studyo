import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../controllers/game_controller.dart';
import '../data/models/game_models.dart';
import '../widgets/draggable_marble_widget.dart';
import '../widgets/color_bar_widget.dart';
import '../widgets/game_header_widget.dart';
import '../widgets/marble_progression_widget.dart';
import 'marble_design_showcase_view.dart';

/// Main view untuk Division Game Screen
class DivisionGameView extends StatelessWidget {
  const DivisionGameView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GameController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDA7BD9), // Pink purple seperti gambar
              Color(0xFFE8A5E8), // Light pink purple
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header dengan instruksi dan equation
                  GameHeaderWidget(controller: controller),

                  // Area permainan utama
                  Expanded(
                    child: Stack(
                      children: [
                        // Color bars di sebelah kiri
                        _buildColorBarsSection(controller),

                        // Area marbles - dengan padding bawah untuk menghindari floating button
                        Padding(
                          padding: const EdgeInsets.only(bottom: 80),
                          child: _buildMarblesSection(controller),
                        ),

                        // Pesan sukses/error
                        _buildResultMessageSection(controller),
                      ],
                    ),
                  ),
                ],
              ),

              // Floating Check Answer Button
              _buildFloatingCheckAnswerButton(controller),

              // Floating Progression Button
              _buildFloatingProgressionButton(context),

              // Floating Design Showcase Button
              _buildFloatingDesignButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget untuk color bars section
  Widget _buildColorBarsSection(GameController controller) {
    return Positioned(
      left: 5, // Mepet ke kiri sesuai gambar referensi
      top: 15, // Lebih atas dan dekat dengan header
      child: Column(
        children: [
          ColorBarWidget(
            color: const Color(0xFFFF9800),
            groupIndex: 0,
            controller: controller,
          ), // Orange
          const SizedBox(height: 8), // Spacing lebih kecil untuk mepet
          ColorBarWidget(
            color: const Color(0xFFFFEB3B),
            groupIndex: 1,
            controller: controller,
          ), // Yellow
          const SizedBox(height: 8), // Spacing lebih kecil untuk mepet
          ColorBarWidget(
            color: const Color(0xFF4CAF50),
            groupIndex: 2,
            controller: controller,
          ), // Green
        ],
      ),
    );
  }

  /// Widget untuk marbles section dengan drag tracking yang akurat
  Widget _buildMarblesSection(GameController controller) {
    return Obx(
      () => Stack(
        children: [
          // Garis penghubung antar marble (layer paling bawah)
          CustomPaint(
            painter: MarbleConnectionPainter(controller.marbles),
            size: Size.infinite,
          ),
          // Marbles (layer atas)
          ...controller.marbles.map((marble) {
            return AnimatedPositioned(
              duration:
                  marble.isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
              left: marble.x,
              top: marble.y,
              child: Container(
                width: 32,
                height: 32,
                child: GestureDetector(
                  onTap: () {
                    // Double tap untuk mengeluarkan marble dari grup
                    if (marble.isInGroup) {
                      controller.removeMarbleFromGroup(marble);
                    }
                  },
                  onPanStart: (details) {
                    marble.isDragging = true;
                    marble.originalX = marble.x;
                    marble.originalY = marble.y;
                    // Simpan posisi awal pan
                    marble.panStartX = details.globalPosition.dx;
                    marble.panStartY = details.globalPosition.dy;
                  },
                  onPanUpdate: (details) {
                    // Drag yang akurat menggunakan perbedaan dari posisi awal pan
                    double deltaX =
                        details.globalPosition.dx - marble.panStartX;
                    double deltaY =
                        details.globalPosition.dy - marble.panStartY;

                    marble.x = marble.originalX + deltaX;
                    marble.y = marble.originalY + deltaY;

                    // Jika marble sudah dalam grup, drag individual (tidak bawa connection group)
                    if (!marble.isInGroup) {
                      // Move connection group organically untuk marble yang belum dalam grup
                      Set<Marble> connectionGroup = marble.getConnectionGroup();
                      if (connectionGroup.length > 1) {
                        // Calculate center position of the group
                        double avgX =
                            connectionGroup
                                .map((m) => m.x)
                                .reduce((a, b) => a + b) /
                            connectionGroup.length;
                        double avgY =
                            connectionGroup
                                .map((m) => m.y)
                                .reduce((a, b) => a + b) /
                            connectionGroup.length;

                        // Calculate offset from old center to new center
                        double newCenterX = marble.x;
                        double newCenterY = marble.y;
                        double offsetX = newCenterX - avgX;
                        double offsetY = newCenterY - avgY;

                        // Move all connected marbles to maintain organic formation
                        for (var connectedMarble in connectionGroup) {
                          if (connectedMarble != marble) {
                            connectedMarble.x += offsetX;
                            connectedMarble.y += offsetY;
                          }
                        }
                      }
                    }

                    // Check magnetic attraction hanya untuk marble floating
                    if (!marble.isInGroup) {
                      for (var otherMarble in controller.marbles) {
                        if (otherMarble != marble &&
                            !otherMarble.isDragging &&
                            !otherMarble.isInGroup &&
                            !marble.connectedMarbles.contains(otherMarble) &&
                            !otherMarble.connectedMarbles.contains(marble)) {
                          double distance = sqrt(
                            pow(marble.x - otherMarble.x, 2) +
                                pow(marble.y - otherMarble.y, 2),
                          );

                          // Magnetic attraction lebih kuat seperti YouTube
                          if (distance < 60 && distance > 30) {
                            double dx = marble.x - otherMarble.x;
                            double dy = marble.y - otherMarble.y;

                            // Semakin dekat, semakin kuat attractionnya
                            double attractionFactor =
                                1 -
                                (distance - 30) /
                                    30; // 0 to 1 based on distance
                            double attractionStrength =
                                0.15 *
                                attractionFactor; // Lebih kuat dari sebelumnya

                            otherMarble.x += dx * attractionStrength;
                            otherMarble.y += dy * attractionStrength;
                          }

                          // Connection pada jarak yang tepat seperti YouTube
                          if (distance < 34) {
                            // Sedikit lebih besar dari ukuran marble (32px)
                            controller.handleUserCollision(marble, otherMarble);
                          }
                        }
                      }
                    }
                    controller.marbles.refresh();
                  },
                  onPanEnd: (details) {
                    marble.isDragging = false;
                    int? groupIndex = _getGroupFromPosition(
                      Offset(marble.x, marble.y),
                    );
                    controller.handleDragEnd(marble, groupIndex);
                  },
                  child: DraggableMarbleWidget(
                    marble: marble,
                    isDragging: marble.isDragging,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Widget untuk result message section
  /// Widget untuk result message (sekarang menggunakan dialog)
  Widget _buildResultMessageSection(GameController controller) {
    // Dialog sudah menggantikan container result message
    return const SizedBox.shrink();
  }

  /// Widget untuk floating check answer button
  Widget _buildFloatingCheckAnswerButton(GameController controller) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF66BB6A), // Light green
              const Color(0xFF4CAF50), // Green
              const Color(0xFF43A047), // Dark green
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap:
                controller.isGameActive.value
                    ? () => controller.checkAnswer()
                    : null,
            child: const Center(
              child: Text(
                'Check Answer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Floating button untuk menampilkan marble progression
  Widget _buildFloatingProgressionButton(BuildContext context) {
    return Positioned(
      right: 20,
      top: 120, // Posisi di atas floating check button
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.purple.shade400,
        onPressed: () {
          _showProgressionDialog(context);
        },
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
      ),
    );
  }

  /// Floating button untuk menampilkan design showcase
  Widget _buildFloatingDesignButton(BuildContext context) {
    return Positioned(
      right: 20,
      top: 80, // Posisi di atas progression button
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.deepPurple.shade600,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MarbleDesignShowcaseView(),
            ),
          );
        },
        child: const Icon(Icons.palette_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  /// Show progression dialog
  void _showProgressionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: const MarbleProgressionWidget(),
          ),
        );
      },
    );
  }

  /// Helper method untuk mendapatkan group index dari posisi drop
  int? _getGroupFromPosition(Offset position) {
    double x = position.dx;
    double y = position.dy;

    // Area drop yang lebih ketat - hanya di sekitar kotak warna (lebih dekat)
    // Kotak berada di x: 5-55, jadi area drop dari x: 0-80 (lebih sempit)
    if (x >= 0 && x <= 80) {
      // Area drop dengan toleransi vertikal yang lebih ketat
      if (y >= 10 && y < 140) return 0; // Orange - area yang lebih ketat
      if (y >= 138 && y < 268) return 1; // Yellow - area yang lebih ketat
      if (y >= 266 && y < 396) return 2; // Light blue - area yang lebih ketat
    }
    return null;
  }
}

/// Custom painter untuk menggambar garis penghubung antar marble
class MarbleConnectionPainter extends CustomPainter {
  final List<Marble> marbles;

  MarbleConnectionPainter(this.marbles);

  @override
  void paint(Canvas canvas, Size size) {
    // Paint untuk garis penghubung - lebih tebal dan kontras seperti di gambar referensi
    final connectionPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    // Paint untuk outline garis agar lebih kontras
    final outlinePaint =
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..strokeWidth = 5.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    // Menggambar garis penghubung antar marble yang terhubung seperti di YouTube
    Set<String> drawnConnections =
        {}; // Untuk menghindari menggambar garis yang sama 2x

    for (var marble in marbles) {
      if (marble.connectedMarbles.isNotEmpty && !marble.isInGroup) {
        Offset marbleCenter = Offset(
          marble.x + 16,
          marble.y + 16,
        ); // Center of 32x32 marble

        // Gambar garis ke semua marble yang terhubung dalam kelompok
        Set<Marble> connectionGroup = marble.getConnectionGroup();
        for (var otherMarble in connectionGroup) {
          if (otherMarble != marble && !otherMarble.isInGroup) {
            // Buat ID unik untuk koneksi untuk menghindari duplikasi
            String connectionId =
                marble.id < otherMarble.id
                    ? '${marble.id}-${otherMarble.id}'
                    : '${otherMarble.id}-${marble.id}';

            if (!drawnConnections.contains(connectionId)) {
              drawnConnections.add(connectionId);

              Offset otherMarbleCenter = Offset(
                otherMarble.x + 16,
                otherMarble.y + 16,
              );

              // Gambar outline hitam dulu
              canvas.drawLine(marbleCenter, otherMarbleCenter, outlinePaint);
              // Gambar garis putih di atasnya seperti YouTube
              canvas.drawLine(marbleCenter, otherMarbleCenter, connectionPaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Selalu repaint untuk update posisi marble
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../controllers/game_controller.dart';
import '../data/models/game_models.dart';
import '../widgets/draggable_marble_widget.dart';
import '../widgets/color_bar_widget.dart';
import '../widgets/game_header_widget.dart';

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
        children:
            controller.marbles.map((marble) {
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
                        // Move connection group hanya untuk marble yang belum dalam grup
                        Set<Marble> connectionGroup =
                            marble.getConnectionGroup();
                        double offsetX = 0;
                        for (var connectedMarble in connectionGroup) {
                          if (connectedMarble != marble) {
                            offsetX += 25;
                            connectedMarble.x = marble.x + offsetX;
                            connectedMarble.y = marble.y;
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

                            // Magnetic attraction dengan zona yang lebih controlled
                            if (distance < 50 && distance > 30) {
                              double dx = marble.x - otherMarble.x;
                              double dy = marble.y - otherMarble.y;
                              double attractionStrength = 0.1;
                              otherMarble.x += dx * attractionStrength;
                              otherMarble.y += dy * attractionStrength;
                            }

                            // Connection hanya terjadi sekali dalam range yang sempit
                            if (distance < 30 &&
                                distance > 28 &&
                                marble.isDragging) {
                              controller.handleUserCollision(
                                marble,
                                otherMarble,
                              );
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

  /// Helper method untuk mendapatkan group index dari posisi drop
  int? _getGroupFromPosition(Offset position) {
    double x = position.dx;
    double y = position.dy;

    // Area drop sesuai dengan posisi kotak warna yang baru (mepet kiri)
    if (x >= 0 && x <= 350) {
      // Area drop dengan posisi Y yang disesuaikan dengan kotak yang lebih mepet
      if (y >= 15 && y < 135) return 0; // Orange - Y: 15 to 135 (15 + 120)
      if (y >= 143 && y < 263)
        return 1; // Yellow - Y: 143 to 263 (15+120+8+120)
      if (y >= 271 && y < 391)
        return 2; // Light blue - Y: 271 to 391 (15+120+8+120+8+120)
    }
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../controllers/game_controller.dart';
import '../models/game_models.dart';
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
              Color(0xFFE1BEE7), // Light purple
              Color(0xFFF3E5F5), // Very light purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header dengan instruksi dan equation
              GameHeaderWidget(controller: controller),

              // Area permainan utama
              Expanded(
                child: Stack(
                  children: [
                    // Color bars di sebelah kiri
                    _buildColorBarsSection(controller),

                    // Area marbles
                    _buildMarblesSection(controller),

                    // Pesan sukses/error
                    _buildResultMessageSection(controller),
                  ],
                ),
              ),

              // Tombol Check Answer
              _buildCheckAnswerButton(controller),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget untuk color bars section
  Widget _buildColorBarsSection(GameController controller) {
    return Positioned(
      left: 20,
      top: 50,
      child: Column(
        children: [
          ColorBarWidget(
            color: const Color(0xFFFF9800),
            groupIndex: 0,
            controller: controller,
          ), // Orange
          const SizedBox(height: 25),
          ColorBarWidget(
            color: const Color(0xFFFFEB3B),
            groupIndex: 1,
            controller: controller,
          ), // Yellow
          const SizedBox(height: 25),
          ColorBarWidget(
            color: const Color(0xFF03A9F4),
            groupIndex: 2,
            controller: controller,
          ), // Light Blue
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
                    onPanStart: (details) {
                      marble.isDragging = true;
                      marble.originalX = marble.x;
                      marble.originalY = marble.y;
                    },
                    onPanUpdate: (details) {
                      // Drag yang benar-benar akurat - marble tepat di jari
                      // Gunakan globalPosition dengan offset yang tepat untuk Stack
                      marble.x = details.globalPosition.dx - 16;
                      marble.y =
                          details.globalPosition.dy -
                          120; // Offset untuk header dan safe area

                      // Move connection group
                      Set<Marble> connectionGroup = marble.getConnectionGroup();
                      double offsetX = 0;
                      for (var connectedMarble in connectionGroup) {
                        if (connectedMarble != marble) {
                          offsetX += 25;
                          connectedMarble.x = marble.x + offsetX;
                          connectedMarble.y = marble.y;
                        }
                      }

                      // Check magnetic attraction
                      for (var otherMarble in controller.marbles) {
                        if (otherMarble != marble &&
                            !otherMarble.isDragging &&
                            !otherMarble.isInGroup &&
                            !marble.connectedMarbles.contains(otherMarble)) {
                          double distance = sqrt(
                            pow(marble.x - otherMarble.x, 2) +
                                pow(marble.y - otherMarble.y, 2),
                          );
                          if (distance < 50) {
                            double dx = marble.x - otherMarble.x;
                            double dy = marble.y - otherMarble.y;
                            otherMarble.x += dx * 0.3;
                            otherMarble.y += dy * 0.3;
                            if (distance < 30) {
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
  Widget _buildResultMessageSection(GameController controller) {
    return Obx(
      () =>
          controller.showResult.value
              ? Positioned(
                top: 50,
                left: 100,
                right: 100,
                child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color:
                            controller.isCorrect.value
                                ? Colors.green
                                : Colors.red,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        controller.isCorrect.value
                            ? 'Correct! Well done!'
                            : 'Try again!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    .animate(controller: controller.celebrationController)
                    .fadeIn(duration: 300.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
              )
              : const SizedBox(),
    );
  }

  /// Widget untuk check answer button
  Widget _buildCheckAnswerButton(GameController controller) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            controller.isGameActive.value
                ? () => controller.checkAnswer()
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        ),
        child: const Text(
          'Check Answer',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Helper method untuk mendapatkan group index dari posisi drop
  int? _getGroupFromPosition(Offset position) {
    double x = position.dx;
    double y = position.dy;

    // Area drop kotak warna diperlebar
    if (x >= 10 && x <= 100) {
      if (y >= 100 && y < 220) return 0; // Orange
      if (y >= 250 && y < 370) return 1; // Yellow
      if (y >= 400 && y < 520) return 2; // Light blue
    }
    return null;
  }
}

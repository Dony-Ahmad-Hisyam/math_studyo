import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../models/game_models.dart';

/// Controller untuk mengelola logika permainan division
class GameController extends GetxController with GetTickerProviderStateMixin {
  // Game state observables
  var dividend = 24.obs;
  var divisor = 3.obs;
  var quotient = 8.obs;
  var marbles = <Marble>[].obs;
  var groups = <RxList<Marble>>[].obs;
  var gameMode = GameMode.simple.obs;
  var isGameActive = true.obs;
  var showResult = false.obs;
  var isCorrect = false.obs;

  // Animation controllers
  late AnimationController animationController;
  late AnimationController celebrationController;

  // Daftar soal yang tersedia
  final List<Map<String, int>> _problems = [
    {'dividend': 12, 'divisor': 3, 'quotient': 4},
    {'dividend': 15, 'divisor': 3, 'quotient': 5},
    {'dividend': 16, 'divisor': 4, 'quotient': 4},
    {'dividend': 18, 'divisor': 3, 'quotient': 6},
    {'dividend': 20, 'divisor': 4, 'quotient': 5},
    {'dividend': 24, 'divisor': 3, 'quotient': 8},
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeAnimationControllers();
    _initializeGame();
  }

  @override
  void onClose() {
    animationController.dispose();
    celebrationController.dispose();
    super.onClose();
  }

  /// Inisialisasi animation controllers
  void _initializeAnimationControllers() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  /// Inisialisasi game state
  void _initializeGame() {
    marbles.clear();
    groups.clear();

    // Initialize only 3 colored groups
    for (int i = 0; i < 3; i++) {
      groups.add(<Marble>[].obs);
    }

    // Create exactly the right number of marbles (dividend value only)
    int totalMarbles = dividend.value;
    int marblesPerRow = 6;
    double screenWidth = 360;
    double gridWidth = marblesPerRow * 38;
    double startXBase = (screenWidth - gridWidth) / 2 + 90;
    double startYBase = 200;
    double spacing = 38;
    var rng = Random();
    for (int i = 0; i < totalMarbles; i++) {
      double jitterX = rng.nextDouble() * 12 - 6; // random offset -6..6
      double jitterY = rng.nextDouble() * 12 - 6;
      double startX = startXBase + (i % marblesPerRow) * spacing + jitterX;
      double startY = startYBase + (i ~/ marblesPerRow) * spacing + jitterY;
      marbles.add(Marble(id: i, x: startX, y: startY, isFloating: true));
    }

    // Reset game state
    isCorrect.value = false;
    showResult.value = false;
    isGameActive.value = true;

    _startFloatingAnimation();
  }

  /// Memulai animasi floating untuk marbles
  void _startFloatingAnimation() {
    animationController.repeat();
    animationController.addListener(() {
      for (var marble in marbles) {
        if (marble.isFloating && !marble.isDragging) {
          marble.updateFloatingPosition(animationController.value);

          // Check for collisions and magnetic attraction
          _checkCollisions(marble);
        }
      }
      marbles.refresh();
    });
  }

  /// Check collisions and handle magnetic attraction
  void _checkCollisions(Marble marble) {
    // No automatic attraction between floating marbles
    // Only handle color bar attraction when dragging
    if (marble.isDragging) {
      for (int i = 0; i < 3; i++) {
        double barX = 50; // Correct position of color bars
        double barY =
            110 + (i * 175); // Adjusted for proper spacing: 110, 285, 460
        double distance = sqrt(
          pow(marble.x - barX, 2) + pow(marble.y - barY, 2),
        );

        if (distance < 100) {
          // Stronger magnetic zone for color bars
          double dx = barX - marble.x;
          double dy = barY - marble.y;
          double force = distance < 50 ? 0.3 : 0.15;
          marble.x += dx * force;
          marble.y += dy * force;
        }
      }
    }
  }

  /// Handle user collision - when user drags one marble into another
  void handleUserCollision(Marble draggedMarble, Marble targetMarble) {
    if (!draggedMarble.isInGroup && !targetMarble.isInGroup) {
      // Connect the marbles
      draggedMarble.connectTo(targetMarble);

      // Visual feedback - make them snap together
      double dx = targetMarble.x - draggedMarble.x;
      double dy = targetMarble.y - draggedMarble.y;
      double distance = sqrt(dx * dx + dy * dy);

      if (distance > 0) {
        // Position them close together
        double snapDistance = 25;
        targetMarble.x = draggedMarble.x + (dx / distance) * snapDistance;
        targetMarble.y = draggedMarble.y + (dy / distance) * snapDistance;
      }

      marbles.refresh();
    }
  }

  /// Menambahkan marble ke group tertentu
  void addMarbleToGroup(Marble marble, int groupIndex) {
    // Find all marbles in the connection group
    Set<Marble> connectionGroup = marble.getConnectionGroup();

    // Add all connected marbles to the same group
    for (var groupMarble in connectionGroup) {
      // Remove from other groups first
      for (var group in groups) {
        group.remove(groupMarble);
      }

      // Add to new group
      if (groupIndex < groups.length) {
        groups[groupIndex].add(groupMarble);
        groupMarble.moveToGroup(groups[groupIndex], groupIndex);
        _arrangeMarbleInGroup(groupMarble, groupIndex);
      }

      // Reset dragging state and clear connections
      groupMarble.isDragging = false;
      groupMarble.connectedMarbles.clear();
    }

    groups.refresh();
  }

  /// Handle drag end for all connected marbles
  void handleDragEnd(Marble mainMarble, int? groupIndex) {
    if (groupIndex != null) {
      addMarbleToGroup(mainMarble, groupIndex);
    } else {
      // Reset all dragging marbles if not dropped on a valid target
      for (var marble in marbles) {
        if (marble.isDragging) {
          marble.isDragging = false;
        }
      }
    }
  }

  /// Mengatur posisi marble dalam group
  void _arrangeMarbleInGroup(Marble marble, int groupIndex) {
    int index = groups[groupIndex].indexOf(marble);

    // Arrange marbles in tight formation in front of the CORRECT color bar
    int row = index ~/ 4; // 4 marbles per row
    int col = index % 4;

    // Position very close to the color bar in organized rows
    marble.x =
        80 + (col * 20); // Closer to box, tight horizontal spacing (20px)
    marble.y =
        110 + (groupIndex * 175) + (row * 20); // Tight vertical spacing (20px)
    marble.isInGroup = true;
  }

  /// Menghapus marble dari group
  void removeMarbleFromGroup(Marble marble) {
    for (var group in groups) {
      group.remove(marble);
    }
    marble.resetToFloating();
    groups.refresh();
  }

  /// Mengecek apakah jawaban benar
  void checkAnswer() {
    if (!isGameActive.value) return;

    // Count non-empty groups
    int filledGroups = 0;
    bool allGroupsEqual = true;
    int expectedSize = quotient.value;

    for (var group in groups) {
      if (group.isNotEmpty) filledGroups++;
      if (group.length != expectedSize) allGroupsEqual = false;
    }

    isCorrect.value = filledGroups == divisor.value && allGroupsEqual;
    showResult.value = true;
    isGameActive.value = false;

    Future.delayed(const Duration(seconds: 2), () {
      showResult.value = false;
      if (isCorrect.value) {
        Future.delayed(const Duration(milliseconds: 500), () {
          resetGame();
        });
      } else {
        isGameActive.value = true;
      }
    });

    if (isCorrect.value) {
      celebrationController.forward(from: 0);
    }
  }

  /// Generate soal baru secara random
  void _generateNewProblem() {
    var problem =
        _problems[DateTime.now().millisecondsSinceEpoch % _problems.length];
    dividend.value = problem['dividend']!;
    divisor.value = problem['divisor']!;
    quotient.value = problem['quotient']!;

    _initializeGame();
  }

  /// Reset game ke kondisi awal
  void resetGame() {
    _initializeGame();
  }

  /// Toggle antara simple dan group mode
  void toggleGameMode() {
    gameMode.value =
        gameMode.value == GameMode.simple ? GameMode.group : GameMode.simple;
  }

  /// Mendapatkan problem saat ini
  DivisionProblem getCurrentProblem() {
    return DivisionProblem(
      dividend: dividend.value,
      divisor: divisor.value,
      quotient: quotient.value,
    );
  }
}

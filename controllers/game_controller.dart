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
        double barX =
            30; // Posisi center kotak (kotak di x=5, width=50, center=30)
        double barY =
            75 + (i * 128); // Center kotak (15 + 120/2 = 75, spacing 128)
        double distance = sqrt(
          pow(marble.x - barX, 2) + pow(marble.y - barY, 2),
        );

        // Magnetic zone yang lebih ketat - hanya aktif sangat dekat dengan kotak
        if (distance < 60) {
          // Dikurangi dari 100
          double dx = barX - marble.x;
          double dy = barY - marble.y;
          double force = distance < 30 ? 0.25 : 0.1; // Dikurangi force
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

      // Arrange connected marbles in organic merged formation like reference image
      _arrangeConnectedMarblesOrganically(draggedMarble);

      marbles.refresh();
    }
  }

  /// Arrange connected marbles in organic merged formation seperti YouTube
  void _arrangeConnectedMarblesOrganically(Marble centerMarble) {
    Set<Marble> connectionGroup = centerMarble.getConnectionGroup();
    List<Marble> marblesList = connectionGroup.toList();

    if (marblesList.length == 1) return; // Single marble, no arrangement needed

    // Find the center position (average of all connected marbles)
    double centerX =
        marblesList.map((m) => m.x).reduce((a, b) => a + b) /
        marblesList.length;
    double centerY =
        marblesList.map((m) => m.y).reduce((a, b) => a + b) /
        marblesList.length;

    // Arrange marbles bersentuhan seperti di video YouTube
    // Marble size 32px, jarak center-to-center = 32px untuk bersentuhan tepat
    const double marbleSpacing = 32.0; // Bersentuhan tepat seperti di YouTube

    for (int i = 0; i < marblesList.length; i++) {
      Marble marble = marblesList[i];

      if (marblesList.length == 2) {
        // Two marbles: bersebelahan dengan jarak tepat (32px) agar terlihat garis penghubungnya
        if (i == 0) {
          marble.x = centerX - marbleSpacing * 0.5; // Jarak 16px dari center
          marble.y = centerY;
        } else {
          marble.x = centerX + marbleSpacing * 0.5; // Jarak 16px dari center
          marble.y = centerY;
        }
      } else if (marblesList.length == 3) {
        // Three marbles: formasi segitiga dengan satu di atas dan dua di bawah seperti gambar
        // Jarak yang cukup untuk memastikan garis penghubung terlihat jelas membentuk segitiga
        double radius =
            marbleSpacing *
            0.6; // Lebih besar agar garis penghubung terlihat jelas

        if (i == 0) {
          // Top marble
          marble.x = centerX;
          marble.y = centerY - radius * 0.7;
        } else if (i == 1) {
          // Bottom left
          marble.x = centerX - radius * 0.7;
          marble.y = centerY + radius * 0.4;
        } else {
          // Bottom right
          marble.x = centerX + radius * 0.7;
          marble.y = centerY + radius * 0.4;
        }
      } else if (marblesList.length == 4) {
        // Four marbles: formasi plus/bunga dengan satu di tengah dan tiga cabang seperti gambar referensi
        double radius =
            marbleSpacing *
            0.75; // Jarak lebih besar agar garis penghubung terlihat jelas

        if (i == 0) {
          // Center marble (berwarna kuning di tengah seperti gambar)
          marble.x = centerX;
          marble.y = centerY;
        } else if (i == 1) {
          // Top petal
          marble.x = centerX;
          marble.y = centerY - radius;
        } else if (i == 2) {
          // Bottom right petal
          marble.x = centerX + radius * 0.866; // cos(30°) * radius
          marble.y = centerY + radius * 0.5; // sin(30°) * radius
        } else {
          // Bottom left petal
          marble.x = centerX - radius * 0.866; // -cos(30°) * radius
          marble.y = centerY + radius * 0.5; // sin(30°) * radius
        }
      } else {
        // More marbles: formasi melingkar dengan jarak yang rapi
        double angle = (i * 2 * pi) / marblesList.length;
        double radius = marbleSpacing * 0.8;
        marble.x = centerX + cos(angle) * radius;
        marble.y = centerY + sin(angle) * radius;
      }
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

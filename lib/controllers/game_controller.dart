import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../data/models/game_models.dart';
import '../services/audio_service.dart';

/// =======================================================================
/// GAME CONTROLLER - Pengontrol Utama untuk Permainan Pembagian
/// =======================================================================
///
/// Controller ini mengelola:
/// 1. State permainan (marbles, groups, skor)
/// 2. Logika drag & drop kelereng
/// 3. Validasi jawaban
/// 4. Audio feedback
/// 5. Animasi dan transisi
///
/// Cara kerja permainan:
/// - Anak drag kelereng untuk mengelompokkan
/// - Sistem validasi mengecek apakah pengelompokan benar
/// - Audio memberikan feedback real-time
/// - Dialog menarik menampilkan hasil
/// =======================================================================

class GameController extends GetxController with GetTickerProviderStateMixin {
  // =======================================================================
  // 🎮 GAME STATE VARIABLES - Variable State Permainan
  // =======================================================================
  var dividend = 24.obs; // Angka yang dibagi (contoh: 24)
  var divisor = 3.obs; // Pembagi (contoh: 3)
  var marbles = <Marble>[].obs; // Daftar semua kelereng
  var groups = <RxList<Marble>>[].obs; // Kelompok kelereng per warna
  var isGameActive = true.obs; // Apakah game sedang aktif
  var showResult = false.obs; // Apakah menampilkan hasil
  var isCorrect = false.obs; // Apakah jawaban benar
  var gameMode = GameMode.simple.obs; // Mode permainan

  // =======================================================================
  // 🔊 AUDIO & ANIMATION SERVICES - Layanan Audio dan Animasi
  // =======================================================================
  final AudioService _audioService = AudioService();
  late AnimationController animationController; // Animasi floating kelereng
  late AnimationController celebrationController; // Animasi perayaan

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
    _audioService.dispose();
    super.onClose();
  }

  // =======================================================================
  // 🚀 INITIALIZATION METHODS - Metode Inisialisasi
  // =======================================================================

  /// Initialize animation controllers
  void _initializeAnimationControllers() {
    animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  /// Initialize game state
  void _initializeGame() {
    marbles.clear();
    groups.clear();

    // Initialize only 3 colored groups
    for (int i = 0; i < 3; i++) {
      groups.add(<Marble>[].obs);
    }

    // Create exactly the right number of marbles dengan posisi yang aman dalam frame
    int totalMarbles = dividend.value;
    double screenWidth =
        400; // Estimasi lebar layar (disesuaikan dengan SafeArea)
    double screenHeight =
        450; // Estimasi tinggi area bermain - dikurangi untuk floating button
    double marbleSize = 32; // Ukuran marble

    double startXBase = 120; // Area marble dimulai dari posisi yang aman
    double startYBase =
        150; // Posisi Y awal setelah header - lebih jauh dari header
    double marbleAreaWidth =
        screenWidth - startXBase - marbleSize - 20; // Margin kanan
    double marbleAreaHeight =
        screenHeight -
        startYBase -
        120; // Margin bawah lebih besar untuk floating button

    var rng = Random();

    // Buat posisi yang acak tapi tetap dalam frame
    for (int i = 0; i < totalMarbles; i++) {
      double x, y;
      bool validPosition = false;
      int attempts = 0;

      do {
        // Posisi acak dalam area yang aman
        x = startXBase + (rng.nextDouble() * marbleAreaWidth);
        y = startYBase + (rng.nextDouble() * marbleAreaHeight);

        // Pastikan tidak keluar dari batas layar
        x = x.clamp(startXBase, screenWidth - marbleSize - 10);
        y = y.clamp(
          startYBase,
          screenHeight - marbleSize - 80,
        ); // Margin lebih besar untuk floating button

        validPosition = true;
        // Cek jarak dengan marble lain
        for (var existingMarble in marbles) {
          double distance = sqrt(
            pow(x - existingMarble.x, 2) + pow(y - existingMarble.y, 2),
          );
          if (distance < 30) {
            // Jarak minimum untuk menghindari overlap
            validPosition = false;
            break;
          }
        }
        attempts++;
      } while (!validPosition &&
          attempts < 80); // Batasi attempt untuk performa

      marbles.add(Marble(id: i, x: x, y: y, isFloating: true));
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
        }
      }
      marbles.refresh();
    });
  }

  // =======================================================================
  // 🎯 MARBLE COLLISION & CONNECTION - Tabrakan dan Koneksi Kelereng
  // =======================================================================

  /// Handle collision between two marbles
  void handleUserCollision(Marble marble1, Marble marble2) {
    // Don't connect if either marble is already in a group
    if (marble1.isInGroup || marble2.isInGroup) return;

    // Connect the marbles - hanya jika belum terhubung sama sekali
    if (!marble1.connectedMarbles.contains(marble2) &&
        !marble2.connectedMarbles.contains(marble1)) {
      // Play audio segera saat collision terjadi (real-time, 1x only)
      _audioService.playMenempelAudio();

      // Connect marbles secara bilateral
      marble1.connectTo(marble2);

      // Arrange marbles in formation sesuai YouTube
      _arrangeConnectedMarblesOrganically(marble1);

      // Force refresh UI
      marbles.refresh();
    }
  }

  /// Update posisi kelereng yang terhubung agar rapi
  void _updateConnectedMarblesPositions(Marble mainMarble) {
    var connectedList = mainMarble.connectedMarbles.toList();
    for (int i = 0; i < connectedList.length; i++) {
      var connectedMarble = connectedList[i];
      // Posisi berurutan dengan jarak yang konsisten
      connectedMarble.x =
          mainMarble.x + (36 * (i + 1)); // Slightly more spacing
      connectedMarble.y = mainMarble.y;
      // Ensure the connected marble is also not dragging
      connectedMarble.isDragging = false;
      connectedMarble.isFloating = false;
    }
    marbles.refresh(); // Force refresh to update positions
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
        // Two marbles: oval horizontal seperti gambar referensi
        if (i == 0) {
          marble.x =
              centerX - marbleSpacing * 0.35; // Lebih mepet untuk bentuk oval
          marble.y = centerY;
        } else {
          marble.x =
              centerX + marbleSpacing * 0.35; // Lebih mepet untuk bentuk oval
          marble.y = centerY;
        }
      } else if (marblesList.length == 3) {
        // Three marbles: formasi segitiga equilateral seperti gambar
        double radius =
            marbleSpacing * 0.37; // Jarak dari pusat ke titik segitiga
        double angle = 2 * pi / 3; // 120 derajat

        // Rotasi segitiga agar satu titik di atas seperti gambar
        double startAngle = -pi / 2; // Mulai dari atas (270 derajat)

        marble.x = centerX + radius * cos(startAngle + i * angle);
        marble.y = centerY + radius * sin(startAngle + i * angle);
      } else if (marblesList.length == 4) {
        // Four marbles: formasi plus/bunga seperti gambar referensi
        double radius = marbleSpacing * 0.37; // Jarak dari pusat ke titik plus

        if (i == 0) {
          marble.x = centerX;
          marble.y = centerY - radius; // Atas
        } else if (i == 1) {
          marble.x = centerX + radius;
          marble.y = centerY; // Kanan
        } else if (i == 2) {
          marble.x = centerX;
          marble.y = centerY + radius; // Bawah
        } else {
          marble.x = centerX - radius;
          marble.y = centerY; // Kiri
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

  // =======================================================================
  // 📦 GROUP MANAGEMENT - Manajemen Kelompok Kelereng
  // =======================================================================

  /// Add marble and its connections to a group
  void addMarbleToGroup(Marble mainMarble, int groupIndex) {
    if (groupIndex >= 0 && groupIndex < groups.length) {
      // Play audio ketika kelereng masuk ke kotak
      _audioService.playMasukKeKotakAudio();

      // Jika marble sudah dalam grup lain, hapus dari grup sebelumnya
      if (mainMarble.isInGroup) {
        int oldGroupIndex = mainMarble.groupIndex;
        if (oldGroupIndex != groupIndex &&
            oldGroupIndex >= 0 &&
            oldGroupIndex < groups.length) {
          groups[oldGroupIndex].remove(mainMarble);
          // Re-arrange marble yang tersisa dalam grup lama
          for (int i = 0; i < groups[oldGroupIndex].length; i++) {
            _arrangeMarbleInGroup(groups[oldGroupIndex][i], oldGroupIndex);
          }
        }
      }

      // Untuk marble yang sudah dalam grup, pindah hanya marble individual (tidak dengan koneksinya)
      if (mainMarble.isInGroup) {
        // Hapus koneksi sebelum pindah ke grup baru
        mainMarble.connectedMarbles.clear();

        // Add hanya marble individual ke grup baru
        if (!groups[groupIndex].contains(mainMarble)) {
          groups[groupIndex].add(mainMarble);
          mainMarble.moveToGroup(groups[groupIndex], groupIndex);
        }
        _arrangeMarbleInGroup(mainMarble, groupIndex);
      } else {
        // Untuk marble floating, ambil seluruh connection group
        Set<Marble> connectionGroup = mainMarble.getConnectionGroup();

        // Add all connected marbles to the group
        for (var groupMarble in connectionGroup) {
          if (!groups[groupIndex].contains(groupMarble)) {
            groups[groupIndex].add(groupMarble);
            groupMarble.moveToGroup(groups[groupIndex], groupIndex);
          }
        }

        // Arrange all marbles in the group
        for (var groupMarble in connectionGroup) {
          _arrangeMarbleInGroup(groupMarble, groupIndex);
        }
      }

      groups.refresh();
      marbles.refresh();
    }
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

    // Arrange marbles dalam 2 baris yang rapi dan menempel di kotak
    int marblesPerRow =
        4; // 4 marble per baris untuk 2 saf yang rapi (maksimal 8 marble per grup)
    int row = index ~/ marblesPerRow;
    int col = index % marblesPerRow;

    // Posisi marble menempel di depan kotak warna yang mepet kiri
    double startX =
        60; // Menempel di depan kotak (kotak di x=5, width=50, jadi x=60)
    double baseY = 15; // Mulai dari Y yang sama dengan kotak pertama yang baru

    // Hitung Y berdasarkan groupIndex dengan spacing yang tepat sesuai kotak baru
    double startY =
        baseY + (groupIndex * 128); // 128 = tinggi kotak (120) + spacing (8)

    marble.x =
        startX + (col * 30); // Spacing 30px antar marble untuk 2 saf yang rapi
    marble.y =
        startY +
        30 +
        (row * 30); // Mulai 30px dari atas kotak, spacing 30px antar baris
    marble.isInGroup = true;
  }

  /// Menghapus marble dari group
  void removeMarbleFromGroup(Marble marble) {
    // Hapus marble individual dari grup (satu per satu)
    if (marble.isInGroup) {
      int groupIndex = marble.groupIndex;
      if (groupIndex >= 0 && groupIndex < groups.length) {
        // Hapus marble dari grup
        groups[groupIndex].remove(marble);

        // Reset marble ke floating state
        marble.resetToFloating();

        // Re-arrange marble yang tersisa dalam grup
        for (int i = 0; i < groups[groupIndex].length; i++) {
          _arrangeMarbleInGroup(groups[groupIndex][i], groupIndex);
        }

        groups.refresh();
        marbles.refresh();
      }
    }
  }

  // =======================================================================
  // ✅ ANSWER VALIDATION & DIALOG - Validasi Jawaban dan Dialog
  // =======================================================================

  /// Mengecek apakah jawaban benar
  void checkAnswer() {
    if (!isGameActive.value) return;

    // Validate answer using ValidationResult model
    ValidationResult result = _validateAnswer();

    isCorrect.value = result.isCorrect;

    // Play audio berdasarkan hasil jawaban
    if (result.isCorrect) {
      _audioService.playJawabanBenarAudio();
      celebrationController.forward().then((_) {
        celebrationController.reset();
      });
      // Show success dialog
      _showAnswerDialog(result.isCorrect);
    } else {
      _audioService.playJawabanSalahAudio();
      // Show error dialog
      _showAnswerDialog(result.isCorrect);
    }
  }

  /// Show attractive dialog for kids with answer result
  void _showAnswerDialog(bool isCorrect) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCorrect ? Icons.star : Icons.refresh,
              color: isCorrect ? Colors.amber : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 8),
            Text(
              isCorrect ? "Excellent!" : "Try Again!",
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                isCorrect
                    ? "🎉 Amazing work! You solved it perfectly! 🎉"
                    : "💪 Don't give up! Try arranging the marbles again! 💪",
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (isCorrect) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  "${dividend.value} ÷ ${divisor.value} = ${dividend.value ~/ divisor.value}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? Colors.green : Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              onPressed: () {
                Get.back(); // Close dialog
                if (isCorrect) {
                  resetGame(); // Start new game if correct
                }
              },
              child: Text(
                isCorrect ? "🚀 Next Challenge!" : "🔄 Try Again",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
      barrierDismissible: false, // User must click the button
    );
  }

  /// Validate current answer and return ValidationResult
  ValidationResult _validateAnswer() {
    // Count non-empty groups
    int filledGroups = 0;
    bool allGroupsEqual = true;
    int expectedSize = dividend.value ~/ divisor.value;
    List<String> errors = [];

    for (var group in groups) {
      if (group.isNotEmpty) {
        filledGroups++;
        if (group.length != expectedSize) {
          allGroupsEqual = false;
          errors.add(
            'Group ${filledGroups} has ${group.length} marbles, expected $expectedSize',
          );
        }
      }
    }

    // Check if the answer is correct
    bool correctGroupCount = filledGroups == divisor.value;
    bool allMarblesUsed =
        groups.fold(0, (sum, group) => sum + group.length) == dividend.value;

    if (!correctGroupCount) {
      errors.add(
        'Expected ${divisor.value} groups, but found $filledGroups groups',
      );
    }

    if (!allMarblesUsed) {
      int usedMarbles = groups.fold(0, (sum, group) => sum + group.length);
      errors.add(
        'Used $usedMarbles marbles, but need to use all ${dividend.value} marbles',
      );
    }

    bool isCorrect = correctGroupCount && allGroupsEqual && allMarblesUsed;

    return isCorrect
        ? ValidationResult.correct()
        : ValidationResult.withErrors(errors);
  }

  // =======================================================================
  // 🔄 GAME RESET & UTILITIES - Reset Game dan Utilitas
  // =======================================================================

  /// Reset game untuk level baru
  void resetGame() {
    _initializeGame();
  }
}

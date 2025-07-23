import 'dart:math';

/// Enum untuk mode permainan
enum GameMode { simple, group }

/// Model untuk marble/bola dalam permainan
class Marble {
  final int id;
  double x;
  double y;
  double originalX;
  double originalY;
  bool isFloating;
  bool isDragging;
  int groupIndex;
  double floatOffset;
  double velocityX;
  double velocityY;
  bool isInGroup;
  double panStartX = 0; // Posisi awal pan untuk drag accuracy
  double panStartY = 0; // Posisi awal pan untuk drag accuracy
  List<Marble> connectedMarbles; // Kelereng yang terhubung dalam grup

  static const double marbleRadius = 12.5; // Radius untuk collision detection

  Marble({
    required this.id,
    required this.x,
    required this.y,
    this.isFloating = true,
    this.isDragging = false,
    this.groupIndex = -1,
  }) : originalX = x,
       originalY = y,
       floatOffset = Random().nextDouble() * 2 * pi, // More random offset
       velocityX =
           (Random().nextDouble() - 0.5) * 4.0, // More random initial velocity
       velocityY = (Random().nextDouble() - 0.5) * 4.0,
       isInGroup = false,
       connectedMarbles = []; // Initialize empty list

  /// Update posisi floating dengan animasi dan physics
  void updateFloatingPosition(double animationValue) {
    // Marbles stay stationary until user interacts with them
    // No automatic movement - marbles only move when dragged by user
    if (isFloating && !isDragging && !isInGroup) {
      // Keep marbles completely still
      // They only move when user drags them
    }
  }

  /// Check if this marble collides with another marble
  bool collidesWith(Marble other) {
    double distance = sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
    return distance < (marbleRadius * 2 + 15); // Spacing for clean movement
  }

  /// Move this marble to align with a group of marbles
  void moveToGroup(List<Marble> groupMarbles, int groupIndex) {
    isInGroup = true;
    isFloating = false;
    this.groupIndex = groupIndex;

    // Arrangement dalam 2 baris di depan kotak warna
    int index = groupMarbles.indexOf(this);
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

    double targetX =
        startX + (col * 30); // Spacing 30px antar marble untuk 2 saf yang rapi
    double targetY =
        startY +
        30 +
        (row * 30); // Mulai 30px dari atas kotak, spacing 30px antar baris

    x = targetX;
    y = targetY;
  }

  /// Reset marble to floating state
  void resetToFloating() {
    isInGroup = false;
    isFloating = true;
    groupIndex = -1;
    connectedMarbles.clear(); // Clear connections
    // Give it some random velocity
    velocityX = (Random().nextDouble() - 0.5) * 4.0;
    velocityY = (Random().nextDouble() - 0.5) * 4.0;
  }

  /// Connect this marble to another marble (user-initiated collision)
  void connectTo(Marble other) {
    if (!connectedMarbles.contains(other)) {
      connectedMarbles.add(other);
      other.connectedMarbles.add(this);
    }
  }

  /// Get all marbles in this connection group
  Set<Marble> getConnectionGroup() {
    Set<Marble> group = {this};
    List<Marble> toCheck = List.from(connectedMarbles);

    while (toCheck.isNotEmpty) {
      Marble marble = toCheck.removeAt(0);
      if (group.add(marble)) {
        // Returns true if marble was added (not already in set)
        toCheck.addAll(marble.connectedMarbles);
      }
    }

    return group;
  }

  /// Move entire connection group when this marble is dragged
  void moveConnectionGroup(double deltaX, double deltaY) {
    Set<Marble> group = getConnectionGroup();
    for (Marble marble in group) {
      if (marble != this) {
        // Don't move self, it's already being dragged
        marble.x += deltaX;
        marble.y += deltaY;
      }
    }
  }
}

/// Model untuk soal pembagian
class DivisionProblem {
  final int dividend;
  final int divisor;
  final int quotient;

  DivisionProblem({
    required this.dividend,
    required this.divisor,
    required this.quotient,
  });

  /// Factory constructor untuk membuat problem dari map
  factory DivisionProblem.fromMap(Map<String, int> map) {
    return DivisionProblem(
      dividend: map['dividend']!,
      divisor: map['divisor']!,
      quotient: map['quotient']!,
    );
  }

  /// Convert ke map
  Map<String, int> toMap() {
    return {'dividend': dividend, 'divisor': divisor, 'quotient': quotient};
  }

  /// Check if the division is valid
  bool get isValid =>
      dividend % divisor == 0 && dividend ~/ divisor == quotient;
}

/// Model untuk grup kelereng
class MarbleGroup {
  final int id;
  final List<Marble> marbles;
  final int expectedCount;
  bool isComplete = false;

  MarbleGroup({
    required this.id,
    required this.expectedCount,
    List<Marble>? initialMarbles,
  }) : marbles = initialMarbles ?? [];

  /// Add marble to group
  void addMarble(Marble marble) {
    if (!marbles.contains(marble)) {
      marbles.add(marble);
      marble.groupIndex = id;
      marble.isInGroup = true;
      _checkCompletion();
    }
  }

  /// Remove marble from group
  void removeMarble(Marble marble) {
    if (marbles.contains(marble)) {
      marbles.remove(marble);
      marble.groupIndex = -1;
      marble.isInGroup = false;
      _checkCompletion();
    }
  }

  /// Clear all marbles from group
  void clear() {
    for (var marble in marbles) {
      marble.groupIndex = -1;
      marble.isInGroup = false;
    }
    marbles.clear();
    isComplete = false;
  }

  /// Check if group is complete
  void _checkCompletion() {
    isComplete = marbles.length == expectedCount;
  }

  /// Get current marble count
  int get currentCount => marbles.length;

  /// Check if group has correct number of marbles
  bool get hasCorrectCount => currentCount == expectedCount;

  /// Check if group is empty
  bool get isEmpty => marbles.isEmpty;

  /// Check if group is not empty
  bool get isNotEmpty => marbles.isNotEmpty;
}

/// Model untuk game state dan progress
class GameState {
  final int level;
  final int score;
  final int totalCorrect;
  final int totalAttempts;
  final DateTime startTime;
  DateTime? endTime;
  bool isCompleted = false;

  GameState({
    this.level = 1,
    this.score = 0,
    this.totalCorrect = 0,
    this.totalAttempts = 0,
    DateTime? startTime,
  }) : startTime = startTime ?? DateTime.now();

  /// Calculate accuracy percentage
  double get accuracy {
    if (totalAttempts == 0) return 0.0;
    return (totalCorrect / totalAttempts) * 100;
  }

  /// Get elapsed time in seconds
  int get elapsedTimeSeconds {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inSeconds;
  }

  /// Mark game as completed
  void complete() {
    isCompleted = true;
    endTime = DateTime.now();
  }

  /// Create new state with updated values
  GameState copyWith({
    int? level,
    int? score,
    int? totalCorrect,
    int? totalAttempts,
    bool? isCompleted,
  }) {
    return GameState(
        level: level ?? this.level,
        score: score ?? this.score,
        totalCorrect: totalCorrect ?? this.totalCorrect,
        totalAttempts: totalAttempts ?? this.totalAttempts,
        startTime: startTime,
      )
      ..endTime = endTime
      ..isCompleted = isCompleted ?? this.isCompleted;
  }
}

/// Model untuk answer validation result
class ValidationResult {
  final bool isCorrect;
  final String message;
  final List<String> errors;

  ValidationResult({
    required this.isCorrect,
    required this.message,
    this.errors = const [],
  });

  /// Factory untuk hasil yang benar
  factory ValidationResult.correct() {
    return ValidationResult(isCorrect: true, message: 'Correct! Well done!');
  }

  /// Factory untuk hasil yang salah
  factory ValidationResult.incorrect({List<String>? errors}) {
    return ValidationResult(
      isCorrect: false,
      message: 'Incorrect answer',
      errors: errors ?? [],
    );
  }

  /// Factory untuk validasi dengan detail errors
  factory ValidationResult.withErrors(List<String> errors) {
    return ValidationResult(
      isCorrect: false,
      message: 'Please check your grouping',
      errors: errors,
    );
  }
}

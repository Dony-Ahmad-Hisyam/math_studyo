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

    // Baris horizontal di depan kotak warna, benar-benar center
    int index = groupMarbles.indexOf(this);
    int col = index % 6;
    int row = index ~/ 6;
    double groupWidth = 6 * 32;
    double centerX = 80 + (groupWidth / 2) - 16; // center di depan kotak
    double targetX = centerX + (col - 2.5) * 32; // -2.5 agar center
    double targetY = 110 + (groupIndex * 175) + (row * 32);
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
}

import 'dart:math';
import '../data/models/game_models.dart';

/// Snippet untuk menata marble dalam formasi
/// File ini hanya referensi, bukan untuk digunakan langsung
/// Gunakan kode ini di dalam class GameController
class MarbleArrangementHelper {
  /// Arrange connected marbles in organic merged formation seperti YouTube
  static void arrangeConnectedMarblesOrganically(Marble centerMarble) {
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

        // Arrange in a triangle with one on top and two at bottom like in reference image
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
}

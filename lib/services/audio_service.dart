import 'package:audioplayers/audioplayers.dart';

/// Service untuk mengelola audio dalam game
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Audio paths
  static const String _menempelAudio = 'assets/menempel.mp3';
  static const String _masukKeKotakAudio = 'assets/masukKeKotak.mp3';
  static const String _jawabanBenarAudio = 'assets/jawabanBenar.mp3';
  static const String _jawabanSalahAudio = 'assets/jawabanSalah.mp3';

  /// Play audio ketika kelereng menempel satu sama lain
  Future<void> playMenempelAudio() async {
    try {
      await _audioPlayer.play(AssetSource('menempel.mp3'));
    } catch (e) {
      print('Error playing menempel audio: $e');
    }
  }

  /// Play audio ketika kelereng masuk ke kotak
  Future<void> playMasukKeKotakAudio() async {
    try {
      await _audioPlayer.play(AssetSource('masukKeKotak.mp3'));
    } catch (e) {
      print('Error playing masukKeKotak audio: $e');
    }
  }

  /// Play audio ketika jawaban benar
  Future<void> playJawabanBenarAudio() async {
    try {
      await _audioPlayer.play(AssetSource('jawabanBenar.mp3'));
    } catch (e) {
      print('Error playing jawabanBenar audio: $e');
    }
  }

  /// Play audio ketika jawaban salah
  Future<void> playJawabanSalahAudio() async {
    try {
      await _audioPlayer.play(AssetSource('jawabanSalah.mp3'));
    } catch (e) {
      print('Error playing jawabanSalah audio: $e');
    }
  }

  /// Stop current playing audio
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  /// Dispose audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}

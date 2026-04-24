import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Servicio centralizado para reproducción de audio
/// Maneja un solo reproductor compartido para toda la app
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Configuración CRÍTICA: Usar PlayerMode.mediaPlayer para Android/iOS
  // En versiones nuevas de audioplayers, el modo por defecto a veces falla.
  final AudioPlayer _player = AudioPlayer(
    playerId: 'kankui_audio_player',
    mode: PlayerMode.mediaPlayer, // Fuerza el reproductor nativo
  );
  
  String? _currentUrl;

  /// Reproduce un audio desde una URL
  /// Retorna true si se inició la reproducción exitosamente
  Future<bool> play(String url) async {
    if (url.isEmpty) {
      debugPrint('[AudioService] URL vacía, no se puede reproducir');
      return false;
    }

    try {
      // Si ya está reproduciendo este audio, lo pausa/reanuda
      if (_currentUrl == url) {
        final state = _player.state;
        if (state == PlayerState.playing) {
          await _player.pause();
          return true;
        } else if (state == PlayerState.paused) {
          await _player.resume();
          return true;
        }
      }

      _currentUrl = url;
      debugPrint('[AudioService] Reproduciendo: $url');

      // Release (libera) cualquier fuente anterior
      await _player.stop();
      
      // Reproduce la nueva URL - Usa UrlSource explícito
      await _player.play(UrlSource(url));

      return true;
    } catch (e) {
      debugPrint('[AudioService] Error reproduciendo audio: $e');
      return false;
    }
  }

  /// Pausa la reproducción actual
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('[AudioService] Error pausando: $e');
    }
  }

  /// Detiene la reproducción y libera recursos
  Future<void> stop() async {
    try {
      await _player.stop();
      _currentUrl = null;
    } catch (e) {
      debugPrint('[AudioService] Error deteniendo: $e');
    }
  }

  /// Reproduce o pausa alternando estado
  Future<void> toggle(String url) async {
    if (_player.state == PlayerState.playing && _currentUrl == url) {
      await pause();
    } else {
      await play(url);
    }
  }

  /// Libera el reproductor cuando la app se cierra
  void dispose() {
    _player.dispose();
  }

  /// Obtiene el estado actual del reproductor
  PlayerState get state => _player.state;
}

/// Wrapper para facilitar el uso en widgets
final audioService = AudioService();

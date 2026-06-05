import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kankui_app/shared/data/local/content_repository.dart';

class DownloadProgress {
  final int downloaded;
  final int total;
  final String? currentLabel;

  DownloadProgress({
    required this.downloaded,
    required this.total,
    this.currentLabel,
  });

  double get fraction => total > 0 ? downloaded / total : 0;
}

class MediaDownloadService {
  static String? _baseDir;
  static String? cachedBaseDir;

  static Future<String> get baseDir async {
    if (_baseDir != null) return _baseDir!;
    final dir = await getApplicationDocumentsDirectory();
    _baseDir = '${dir.path}/media';
    final mediaDir = Directory(_baseDir!);
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    cachedBaseDir = _baseDir;
    return _baseDir!;
  }

  static final Dio _dio = Dio();

  static Stream<DownloadProgress> downloadAll() async* {
    final dir = await baseDir;
    final repo = ContentRepository();
    final palabras = await repo.getPalabras();

    int completed = 0;
    final total = palabras.length * 2;

    for (final p in palabras) {
      if (p.audioUrl != null && p.audioUrl!.isNotEmpty) {
        yield DownloadProgress(
          downloaded: completed,
          total: total,
          currentLabel: '${p.termino} (audio)',
        );
        final audioPath = '$dir/${p.id}.mp3';
        if (!await File(audioPath).exists()) {
          try {
            await _dio.download(p.audioUrl!, audioPath);
          } catch (_) {}
        }
        completed++;
      }

      if (p.imageUrl != null && p.imageUrl!.isNotEmpty) {
        yield DownloadProgress(
          downloaded: completed,
          total: total,
          currentLabel: '${p.termino} (imagen)',
        );
        final imgPath = '$dir/${p.id}.png';
        if (!await File(imgPath).exists()) {
          try {
            await _dio.download(p.imageUrl!, imgPath);
          } catch (_) {}
        }
        completed++;
      }
    }

    yield DownloadProgress(
      downloaded: total,
      total: total,
      currentLabel: '¡Completado!',
    );
  }

  static String resolveAudioSync(String palabraId, String url) {
    if (cachedBaseDir == null) return url;
    final local = '$cachedBaseDir/$palabraId.mp3';
    if (File(local).existsSync()) return local;
    return url;
  }

  static String resolveImageSync(String palabraId, String url) {
    if (cachedBaseDir == null) return url;
    final local = '$cachedBaseDir/$palabraId.png';
    if (File(local).existsSync()) return local;
    return url;
  }

  static Future<bool> audioExists(String palabraId) async {
    final dir = await baseDir;
    return File('$dir/$palabraId.mp3').exists();
  }

  static Future<bool> imageExists(String palabraId) async {
    final dir = await baseDir;
    return File('$dir/$palabraId.png').exists();
  }

  static Future<int> totalSize() async {
    final dir = Directory(await baseDir);
    if (!await dir.exists()) return 0;
    int total = 0;
    await for (final entity in dir.list()) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  static Future<void> clearAll() async {
    final dir = Directory(await baseDir);
    if (await dir.exists()) await dir.delete(recursive: true);
    _baseDir = null;
    cachedBaseDir = null;
  }
}

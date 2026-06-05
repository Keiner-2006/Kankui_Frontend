import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kankui_app/shared/services/media_download_service.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
class DownloadProgressScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  const DownloadProgressScreen({
    super.key,
    required this.onComplete,
    this.onSkip,
  });
  @override
  State<DownloadProgressScreen> createState() => _DownloadProgressScreenState();
}
class _DownloadProgressScreenState extends State<DownloadProgressScreen> {
  double _progress = 0;
  String _currentLabel = 'Preparando...';
  bool _isComplete = false;
  StreamSubscription<DownloadProgress>? _subscription;
  @override
  void initState() {
    super.initState();
    _startDownload();
  }
  Future<void> _startDownload() async {
    
    final dir = await MediaDownloadService.baseDir;
    MediaDownloadService.cachedBaseDir = dir;
    final stream = MediaDownloadService.downloadAll();
    _subscription = stream.listen(
      (progress) {
        if (!mounted) return;
        setState(() {
          _progress = progress.fraction;
          _currentLabel = progress.currentLabel ?? 'Descargando...';
          _isComplete = progress.fraction >= 1.0;
        });
      },
      onDone: () {
        if (!mounted) return;
      },
    );
  }
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  Future<void> _handleContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('media_downloaded', true);
    widget.onComplete();
  }
  Future<void> _handleSkip() async {
    _subscription?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('media_skipped', true);
    widget.onSkip?.call();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.terracota.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: _isComplete
                    ? const Icon(
                        Icons.check_circle_rounded,
                        size: 64,
                        color: AppColors.verdeSelva,
                      )
                    : const Icon(
                        Icons.download_rounded,
                        size: 64,
                        color: AppColors.terracota,
                      ),
              ),
              const SizedBox(height: 32),
              Text(
                _isComplete
                    ? '¡Todo listo!'
                    : 'Preparando tus lecciones',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textoOscuro,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                _isComplete
                    ? 'Los audios e imágenes están descargados.\nPuedes usar la app sin conexión.'
                    : 'Estamos descargando el contenido\npara que funcione sin internet.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textoMedio,
                    ),
              ),
              const SizedBox(height: 40),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 10,
                  backgroundColor: AppColors.cremaOscuro,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.terracota,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _currentLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textoClaro,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.terracota,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(flex: 2),
              if (_isComplete)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracota,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Comenzar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracota.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Descargando...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _handleSkip,
                  child: const Text(
                    'Omitir, descargar después',
                    style: TextStyle(
                      color: AppColors.textoClaro,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

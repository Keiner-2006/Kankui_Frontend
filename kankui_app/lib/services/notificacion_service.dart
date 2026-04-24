import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // 🔥 INIT
  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // 🔐 Permiso Android 13+
    await androidPlugin?.requestNotificationsPermission();

    // 🔔 CANALES (OBLIGATORIO ANDROID 8+)
    await _createChannels(androidPlugin);

    _initialized = true;
  }

  // 🔥 CANALES
  static Future<void> _createChannels(
    AndroidFlutterLocalNotificationsPlugin? androidPlugin,
  ) async {
    const channels = [
      AndroidNotificationChannel(
        'auth_channel',
        'Autenticación',
        importance: Importance.max,
      ),
      AndroidNotificationChannel(
        'lesson_channel',
        'Lecciones',
        importance: Importance.max,
      ),
      AndroidNotificationChannel(
        'general_channel',
        'General',
        importance: Importance.high,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin?.createNotificationChannel(channel);
    }
  }

  // 🔥 NOTIFICACIÓN GENERAL
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'general_channel',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id,
      title,
      body,
      details,
    );
  }

  // 👋 BIENVENIDA LOGIN
  static Future<void> showWelcome(String userName) async {
    const androidDetails = AndroidNotificationDetails(
      'auth_channel',
      'Autenticación',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      'Bienvenido 👋',
      'Hola $userName, continúa aprendiendo Kakatukwa-Lingo',
      details,
    );
  }

  // 🎓 LECCIÓN COMPLETADA
  static Future<void> showLessonCompleted(String lessonName) async {
    const androidDetails = AndroidNotificationDetails(
      'lesson_channel',
      'Lecciones',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      2,
      '¡Lección completada! 🎉',
      'Has terminado: $lessonName',
      details,
    );
  }

  // 📚 PROGRESO AUTOMÁTICO (50%, 80%, 100%)
  static Future<void> showProgress(int percent) async {
    const androidDetails = AndroidNotificationDetails(
      'lesson_channel',
      'Lecciones',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      3,
      'Tu progreso 📊',
      'Has alcanzado $percent% de tu aprendizaje',
      details,
    );
  }
}
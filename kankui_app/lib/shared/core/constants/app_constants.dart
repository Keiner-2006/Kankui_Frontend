import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String appName = 'Kankui';
  static const String appVersion = '1.0.0';
  static const String appSubtitle = 'Lengua Kankuamo';
  static const String institutionName = 'I.E. Indígena Atánquez';
  static const String institutionLocation = 'Sierra Nevada';
}

class ApiConstants {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://jghnbyuanxxhtpllazmq.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}

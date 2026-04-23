import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'data/local/palabra_local.dart';
import 'models/palabra.dart';
import 'data/sync/sync_service.dart';
import 'data/remote/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 INICIALIZAR SUPABASE (ANTES DE TODO)
  await Supabase.initialize(
    url: 'https://jghnbyuanxxhtpllazmq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpnaG5ieXVhbnh4aHRwbGxhem1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1MTc5MzUsImV4cCI6MjA5MTA5MzkzNX0.fboYT3pGgMKXDmaKNvfYr9FJ94cxnaoEiKRwz_h6cTY',
  );

  final palabraLocal = PalabraLocal();

  final syncService = SyncService();

  await palabraLocal.insertarPalabra("hola", "hello");

  await syncService.sincronizarPalabras();


  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const KankuiApp());
}

class KankuiApp extends StatelessWidget {
  const KankuiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kankui - Lengua Kankuamo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppColors {
  // Colores principales - Paleta inspirada en la Sierra Nevada
  static const Color terracota = Color(0xFF8D4925);
  static const Color terracotaLight = Color(0xFFB56D45);
  static const Color terracotaDark = Color(0xFF6B3419);
  
  static const Color crema = Color(0xFFFDF5E6);
  static const Color cremaOscuro = Color(0xFFF5E6D3);
  
  // Colores secundarios - Naturaleza de la Sierra
  static const Color verdeSelva = Color(0xFF2D5A3D);
  static const Color verdeMontana = Color(0xFF4A7C59);
  static const Color azulCielo = Color(0xFF5B8FA8);
  static const Color doradoSol = Color(0xFFD4A84B);
  
  // Colores de texto
  static const Color textoOscuro = Color(0xFF2C2416);
  static const Color textoMedio = Color(0xFF5D4E3C);
  static const Color textoClaro = Color(0xFF8B7355);
  
  // Colores de estado
  static const Color exito = Color(0xFF4A7C59);
  static const Color error = Color(0xFFB54545);
  static const Color advertencia = Color(0xFFD4A84B);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.terracota,
      scaffoldBackgroundColor: AppColors.crema,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.terracota,
        primary: AppColors.terracota,
        secondary: AppColors.verdeSelva,
        surface: AppColors.crema,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textoOscuro,
      ),
      
      // Tipografía orgánica
      textTheme: GoogleFonts.nunitoTextTheme(const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textoOscuro,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textoOscuro,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textoOscuro,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textoOscuro,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textoOscuro,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textoMedio,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textoMedio,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textoMedio,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.terracota,
        ),
      )),
      
      // Botones con bordes orgánicos
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracota,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.terracota,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: const BorderSide(color: AppColors.terracota, width: 2),
        ),
      ),
      
      // Cards con estilo orgánico
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // AppBar transparente
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.terracota),
        titleTextStyle: TextStyle(
          color: AppColors.textoOscuro,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.terracota,
        unselectedItemColor: AppColors.textoClaro,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      
      // Input decorations
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.cremaOscuro, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.terracota, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.terracota,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}

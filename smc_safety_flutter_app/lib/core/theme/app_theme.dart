import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(AppConstants.colorBackground),
      colorScheme: const ColorScheme.dark(
        background: Color(AppConstants.colorBackground),
        surface: Color(AppConstants.colorSurface),
        primary: Color(AppConstants.colorAccent),
        secondary: Color(AppConstants.colorGreen),
        error: Color(AppConstants.colorRed),
      ),
      cardTheme: CardTheme(
        color: const Color(AppConstants.colorCard),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFF1E3A5F),
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppConstants.colorSurface),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(AppConstants.colorAccent),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: Color(AppConstants.colorAccent)),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(AppConstants.colorText)),
        bodyMedium: TextStyle(color: Color(AppConstants.colorText)),
        bodySmall: TextStyle(color: Color(AppConstants.colorTextMuted)),
        titleLarge: TextStyle(
          color: Color(AppConstants.colorText),
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: Color(AppConstants.colorText),
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: Color(AppConstants.colorTextMuted),
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: Color(AppConstants.colorAccent),
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.colorAccent),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(AppConstants.colorSurface),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppConstants.colorAccent), width: 2),
        ),
        hintStyle: const TextStyle(color: Color(AppConstants.colorTextMuted)),
        labelStyle: const TextStyle(color: Color(AppConstants.colorTextMuted)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(AppConstants.colorSurface),
        selectedItemColor: Color(AppConstants.colorAccent),
        unselectedItemColor: Color(AppConstants.colorTextMuted),
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E3A5F),
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: Color(AppConstants.colorAccent),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(AppConstants.colorAccent);
          }
          return const Color(AppConstants.colorTextMuted);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(AppConstants.colorAccent).withOpacity(0.4);
          }
          return const Color(AppConstants.colorTextMuted).withOpacity(0.3);
        }),
      ),
    );
  }

  static Color riskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return const Color(AppConstants.colorRed);
      case 'MEDIUM':
        return const Color(AppConstants.colorYellow);
      case 'LOW':
      default:
        return const Color(AppConstants.colorGreen);
    }
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(AppConstants.colorRed);
      case 'resolved':
        return const Color(AppConstants.colorGreen);
      case 'pending':
        return const Color(AppConstants.colorYellow);
      default:
        return const Color(AppConstants.colorTextMuted);
    }
  }
}

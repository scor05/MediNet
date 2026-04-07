import 'package:flutter/material.dart';

class AppTheme {
  // Paleta  MediNet
  static const Color primary = Color(0xFF0F172A); // botón principal
  static const Color secondary = Color(0xFF2563EB); //botón secundario
  static const Color background = Color(0xFFE0F2FE); // fondos
  static const Color accent = Color(0xFF38BDF8); //  header/ola
  static const Color textPrimary = Color(0xFF334155); // texto principal
  static const Color textSecondary = Color(
    0xFF64748B,
  ); // texto secundario/hints
  static const Color border = Color(0xFFBAE6FD); // bordes de campos
  static const Color error = Color(0xFFE53E5A); // errores

  static ThemeData get theme => ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: background,
      error: error,
    ),

    // ElevatedButton global — colores forzados para toda la app
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return primary.withAlpha(128);
          }
          return primary;
        }),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        elevation: WidgetStateProperty.all(0),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: border, width: 1.5),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: secondary, width: 1.5),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: error, width: 1.5),
      ),
    ),
  );

  // Botón principal
  static ButtonStyle get btnDark => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.disabled)) return primary.withAlpha(128);
      return primary;
    }),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
    shadowColor: WidgetStateProperty.all(Colors.transparent),
    minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    elevation: WidgetStateProperty.all(0),
  );

  // Botón secundario
  static ButtonStyle get btnLight => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.disabled)) {
        return secondary.withAlpha(128);
      }
      return secondary;
    }),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
    shadowColor: WidgetStateProperty.all(Colors.transparent),
    minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    elevation: WidgetStateProperty.all(0),
  );
}

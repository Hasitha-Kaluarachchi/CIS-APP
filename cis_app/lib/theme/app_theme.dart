import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF2F80ED);
  static const Color lightBlue = Color(0xFF56CCF2);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color buttonColor = Color(0xFF2F80ED);
  static const Color buttonBorder = Color(0xFF2F80ED);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE9EDFF), Color(0xFFDDE6FF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFEAF6FF)],
  );

  static const TextStyle brandTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: primaryBlue,
    letterSpacing: 0.4,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textDark,
  );

  static InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12, color: textSecondary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: primaryBlue, width: 1.4),
      ),
    );
  }

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonColor,
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: const Size(double.infinity, 42),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );
}

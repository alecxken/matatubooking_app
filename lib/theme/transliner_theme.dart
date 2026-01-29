// lib/theme/transliner_theme.dart
import 'package:flutter/material.dart';

class TranslinerTheme {
  // Primary Colors
  static const Color primaryRed = Color(0xFFDC2626);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color darkRed = Color(0xFFB91C1C);
  static const Color errorRed = Color(0xFFDC2626);

  // Secondary Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color warningYellow = Color(0xFFF59E0B);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color charcoal = Color(0xFF1F2937);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color lightGray = Color(0xFFF9FAFB);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, darkRed],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [infoBlue, Color(0xFF1E40AF)],
  );
}

class TranslinerShadows {
  static const List<BoxShadow> primaryShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> subtleShadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
}

class TranslinerDecorations {
  static BoxDecoration get premiumCard => BoxDecoration(
    color: TranslinerTheme.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: TranslinerShadows.cardShadow,
    border: Border.all(color: TranslinerTheme.gray100),
  );

  static BoxDecoration get primaryButton => BoxDecoration(
    gradient: TranslinerTheme.primaryGradient,
    borderRadius: BorderRadius.circular(12),
    boxShadow: TranslinerShadows.primaryShadow,
  );
}

class TranslinerSpacing {
  static const EdgeInsets pagePadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(12.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0,
  );
}

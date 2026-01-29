// lib/theme/transliner_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TransLine App Theme
/// Uses Inter font family (San Francisco-like) for consistent, modern typography
/// Material 3 design system with custom TransLine branding
class TranslinerTheme {
  // ============================================================================
  // COLOR PALETTE
  // ============================================================================

  /// Primary Colors - Red brand identity
  static const Color primaryRed = Color(0xFFDC2626); // Red-600
  static const Color primaryContainer = Color(0xFFFEE2E2); // Red-100
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF7F1D1D); // Red-900

  static const Color accentRed = Color(0xFFEF4444); // Red-500
  static const Color darkRed = Color(0xFFB91C1C); // Red-700
  static const Color errorRed = Color(0xFFDC2626);

  /// Secondary Colors
  static const Color secondary = Color(0xFFEF4444); // Red-500
  static const Color secondaryContainer = Color(0xFFFEF2F2); // Red-50
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF991B1B); // Red-800

  /// Semantic Colors
  static const Color successGreen = Color(0xFF10B981); // Emerald-500
  static const Color successContainer = Color(0xFFD1FAE5); // Emerald-100
  static const Color infoBlue = Color(0xFF3B82F6); // Blue-500
  static const Color infoContainer = Color(0xFFDBEAFE); // Blue-100
  static const Color warningYellow = Color(0xFFF59E0B); // Amber-500
  static const Color warningContainer = Color(0xFFFEF3C7); // Amber-100

  /// Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF9FAFB); // Gray-50
  static const Color onSurface = Color(0xFF1F2937); // Gray-800
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Gray-500

  /// Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color charcoal = Color(0xFF1F2937); // Gray-800
  static const Color gray900 = Color(0xFF111827);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color lightGray = Color(0xFFF9FAFB);

  /// Border Colors
  static const Color outline = Color(0xFFD1D5DB); // Gray-300
  static const Color outlineVariant = Color(0xFFE5E7EB); // Gray-200

  // ============================================================================
  // GRADIENTS
  // ============================================================================

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

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successGreen, Color(0xFF059669)],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
    colors: [
      Color(0xFFE5E7EB),
      Color(0xFFF3F4F6),
      Color(0xFFE5E7EB),
    ],
  );

  // ============================================================================
  // MATERIAL 3 THEME DATA
  // ============================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        primaryContainer: primaryContainer,
        onPrimary: onPrimary,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        onSecondary: onSecondary,
        onSecondaryContainer: onSecondaryContainer,
        error: errorRed,
        onError: white,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),

      // Typography - Inter font (San Francisco-like)
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // Display styles
        displayLarge: GoogleFonts.inter(
          fontSize: 57,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.25,
          color: charcoal,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: charcoal,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: charcoal,
        ),

        // Headline styles
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: charcoal,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: charcoal,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: charcoal,
        ),

        // Title styles
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: charcoal,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: charcoal,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: gray600,
        ),

        // Body styles
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: charcoal,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: charcoal,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: gray600,
        ),

        // Label styles
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: charcoal,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: gray600,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: gray500,
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryRed,
        foregroundColor: white,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
          letterSpacing: 0,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: gray200, width: 1),
        ),
        color: white,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryRed,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryRed,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: primaryRed, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryRed,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gray50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gray300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gray300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: gray600,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: gray400,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: gray100,
        selectedColor: primaryContainer,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 24,
        backgroundColor: white,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: gray600,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: white,
        elevation: 16,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: gray200,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// ============================================================================
// SHADOWS
// ============================================================================

class TranslinerShadows {
  /// Level 1 - Subtle shadow for slight elevation
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Level 2 - Card shadow for standard cards
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Level 3 - Elevated shadow for raised elements
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Level 4 - Modal shadow for modals and dialogs
  static const List<BoxShadow> level4 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 15,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
  ];

  /// Level 5 - Maximum shadow for floating elements
  static const List<BoxShadow> level5 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 25,
      offset: Offset(0, 20),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 10),
    ),
  ];

  // Legacy aliases
  static const List<BoxShadow> primaryShadow = level3;
  static const List<BoxShadow> cardShadow = level2;
  static const List<BoxShadow> subtleShadow = level1;
}

// ============================================================================
// DECORATIONS
// ============================================================================

class TranslinerDecorations {
  /// Premium card decoration with border and shadow
  static BoxDecoration get premiumCard => BoxDecoration(
    color: TranslinerTheme.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: TranslinerShadows.cardShadow,
    border: Border.all(color: TranslinerTheme.gray200),
  );

  /// Simple card decoration without border
  static BoxDecoration get simpleCard => BoxDecoration(
    color: TranslinerTheme.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: TranslinerShadows.cardShadow,
  );

  /// Primary button decoration with gradient
  static BoxDecoration get primaryButton => BoxDecoration(
    gradient: TranslinerTheme.primaryGradient,
    borderRadius: BorderRadius.circular(12),
    boxShadow: TranslinerShadows.primaryShadow,
  );

  /// Surface decoration for containers
  static BoxDecoration get surface => BoxDecoration(
    color: TranslinerTheme.surfaceVariant,
    borderRadius: BorderRadius.circular(12),
  );

  /// Outlined container decoration
  static BoxDecoration get outlined => BoxDecoration(
    color: TranslinerTheme.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: TranslinerTheme.outline),
  );
}

// ============================================================================
// SPACING
// ============================================================================

class TranslinerSpacing {
  // Standard spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Edge Insets
  static const EdgeInsets pagePadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: 14.0,
  );
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: md);

  // SizedBox spacing
  static const SizedBox verticalSpaceXS = SizedBox(height: xs);
  static const SizedBox verticalSpaceSM = SizedBox(height: sm);
  static const SizedBox verticalSpaceMD = SizedBox(height: md);
  static const SizedBox verticalSpaceLG = SizedBox(height: lg);
  static const SizedBox verticalSpaceXL = SizedBox(height: xl);

  static const SizedBox horizontalSpaceXS = SizedBox(width: xs);
  static const SizedBox horizontalSpaceSM = SizedBox(width: sm);
  static const SizedBox horizontalSpaceMD = SizedBox(width: md);
  static const SizedBox horizontalSpaceLG = SizedBox(width: lg);
  static const SizedBox horizontalSpaceXL = SizedBox(width: xl);
}

// ============================================================================
// BORDER RADIUS
// ============================================================================

class TranslinerRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;

  static BorderRadius get borderSM => BorderRadius.circular(sm);
  static BorderRadius get borderMD => BorderRadius.circular(md);
  static BorderRadius get borderLG => BorderRadius.circular(lg);
  static BorderRadius get borderXL => BorderRadius.circular(xl);
  static BorderRadius get borderFull => BorderRadius.circular(full);
}

// ============================================================================
// DURATIONS
// ============================================================================

class TranslinerDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

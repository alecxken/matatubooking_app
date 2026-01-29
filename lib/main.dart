import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/trip_provider.dart';
import 'providers/app_settings_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_screen.dart';
import 'screens/trip/trip_detail_screen.dart';
import 'screens/trip/seat_selection_screen.dart';
import 'screens/trip/payment_screen.dart';
import 'screens/settings/app_settings_screen.dart';
import 'screens/operations/operations_screen.dart';
import 'theme/transliner_theme.dart';

void main() {
  runApp(const TranslinerCruiserApp());
}

class TranslinerCruiserApp extends StatelessWidget {
  const TranslinerCruiserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'Transliner Cruiser',
            theme: _buildTheme(),
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: TranslinerTheme.primaryRed,
      scaffoldBackgroundColor: TranslinerTheme.lightGray,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TranslinerTheme.primaryRed,
        primary: TranslinerTheme.primaryRed,
        secondary: TranslinerTheme.accentRed,
        tertiary: TranslinerTheme.infoBlue,
        error: TranslinerTheme.errorRed,
        surface: TranslinerTheme.white,
        brightness: Brightness.light,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: TranslinerTheme.primaryRed,
        foregroundColor: TranslinerTheme.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: TranslinerTheme.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: TranslinerTheme.white,
              shadowColor: Colors.transparent,
              padding: TranslinerSpacing.buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
            ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TranslinerTheme.primaryRed,
          foregroundColor: TranslinerTheme.white,
          padding: TranslinerSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TranslinerTheme.primaryRed,
          side: const BorderSide(color: TranslinerTheme.primaryRed, width: 2),
          padding: TranslinerSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: TranslinerTheme.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TranslinerTheme.gray100),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TranslinerTheme.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TranslinerTheme.gray400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TranslinerTheme.gray400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: TranslinerTheme.primaryRed,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TranslinerTheme.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: TranslinerTheme.errorRed,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Text Themes
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: TranslinerTheme.charcoal,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: TranslinerTheme.charcoal,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: TranslinerTheme.charcoal,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: TranslinerTheme.charcoal,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: TranslinerTheme.charcoal,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: TranslinerTheme.charcoal,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: TranslinerTheme.charcoal,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: TranslinerTheme.charcoal,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: TranslinerTheme.charcoal,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: TranslinerTheme.charcoal),
        bodyMedium: TextStyle(color: TranslinerTheme.charcoal),
        bodySmall: TextStyle(color: TranslinerTheme.gray600),
        labelLarge: TextStyle(
          color: TranslinerTheme.charcoal,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: TranslinerTheme.gray600,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: TranslinerTheme.gray600,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TranslinerTheme.white,
        selectedItemColor: TranslinerTheme.primaryRed,
        unselectedItemColor: TranslinerTheme.gray600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: TranslinerTheme.white,
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: TranslinerTheme.primaryRed,
        foregroundColor: TranslinerTheme.white,
        elevation: 6,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: TranslinerTheme.primaryRed,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: TranslinerTheme.gray100,
        thickness: 1,
        space: 1,
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: authProvider.isAuthenticated ? '/home' : '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.uri.toString() == '/login';

        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }

        if (isAuthenticated && isLoggingIn) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
        GoRoute(
          path: '/trip/:tripToken',
          builder: (context, state) {
            final tripToken = state.pathParameters['tripToken']!;
            return TripDetailScreen(tripToken: tripToken);
          },
        ),
        GoRoute(
          path: '/trip/:tripToken/seats',
          builder: (context, state) {
            final tripToken = state.pathParameters['tripToken']!;
            return SeatSelectionScreen(tripToken: tripToken);
          },
        ),
        GoRoute(
          path: '/trip/:tripToken/payment',
          builder: (context, state) {
            final tripToken = state.pathParameters['tripToken']!;
            final extra = state.extra as Map<String, dynamic>?;
            return PaymentScreen(
              tripToken: tripToken,
              selectedSeats: extra?['selectedSeats'] ?? [],
              passengerDetails: extra?['passengerDetails'] ?? {},
              totalAmount: extra?['totalAmount'] ?? 0,
              trip: extra?['trip'] ?? {},
            );
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const AppSettingsScreen(),
        ),
        GoRoute(
          path: '/operations',
          builder: (context, state) => const OperationsScreen(),
        ),
      ],
    );
  }
}

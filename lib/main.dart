import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/trip_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/trip_management_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_screen.dart';
import 'screens/trip/trip_detail_screen.dart';
import 'screens/trip/seat_selection_screen.dart';
import 'screens/trip/payment_screen.dart';
import 'screens/settings/app_settings_screen.dart';
import 'screens/operations/operations_screen.dart';
import 'screens/trip_management/owner_management_screen.dart';
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
        ChangeNotifierProvider(create: (_) => TripManagementProvider()),
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
    // Use the comprehensive Material 3 theme with San Francisco-like typography
    return TranslinerTheme.lightTheme.copyWith(
      scaffoldBackgroundColor: TranslinerTheme.lightGray,
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
        GoRoute(
          path: '/operations/owners',
          builder: (context, state) => const OwnerManagementScreen(),
        ),
      ],
    );
  }
}

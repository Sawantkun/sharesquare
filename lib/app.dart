import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/login_screen.dart';
import 'screens/onboarding/signup_screen.dart';
import 'screens/onboarding/forgot_password_screen.dart';
import 'screens/main/main_shell.dart';
import 'screens/expenses/add_expense_screen.dart';
import 'screens/chores/add_chore_screen.dart';
import 'screens/analytics/analytics_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (_, __) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (_, __) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, state) {
        final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
        return MainShell(initialIndex: tab);
      },
      routes: [
        GoRoute(
          path: 'analytics',
          builder: (_, __) => const AnalyticsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/analytics',
      builder: (_, __) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/add-expense',
      builder: (_, __) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/add-chore',
      builder: (_, __) => const AddChoreScreen(),
    ),
  ],
);

class ShareSquareApp extends StatelessWidget {
  const ShareSquareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'ShareSquare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}

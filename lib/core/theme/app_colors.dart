import 'package:flutter/material.dart';

class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary     = Color(0xFF6366F1); // indigo
  static const Color primarySoft = Color(0xFF818CF8);
  static const Color primaryDeep = Color(0xFF4338CA);
  static const Color secondary   = Color(0xFF06C8A8); // teal
  static const Color accent      = Color(0xFFFF5C72); // coral-red
  static const Color gold        = Color(0xFFFBBF24);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient brand = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient brandRadial = LinearGradient(
    colors: [Color(0xFF818CF8), Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient teal = LinearGradient(
    colors: [Color(0xFF06C8A8), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient coral = LinearGradient(
    colors: [Color(0xFFFF5C72), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient violet = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light palette ──────────────────────────────────────────────────────────
  static const Color bgLight       = Color(0xFFF8F8FC);
  static const Color surfaceLight  = Color(0xFFFFFFFF);
  static const Color cardLight     = Color(0xFFFFFFFF);
  static const Color borderLight   = Color(0xFFEAEAF4);
  static const Color dividerLight  = Color(0xFFF2F2F8);
  static const Color t1Light       = Color(0xFF0F0F1A); // primary text
  static const Color t2Light       = Color(0xFF5C5C7A); // secondary text
  static const Color t3Light       = Color(0xFFABABC4); // tertiary / hint

  // ── Dark palette ───────────────────────────────────────────────────────────
  static const Color bgDark        = Color(0xFF0C0C14);
  static const Color surfaceDark   = Color(0xFF14141E);
  static const Color cardDark      = Color(0xFF1A1A28);
  static const Color cardDark2     = Color(0xFF222233);
  static const Color borderDark    = Color(0xFF2A2A3E);
  static const Color dividerDark   = Color(0xFF1E1E2C);
  static const Color t1Dark        = Color(0xFFF0F0FF);
  static const Color t2Dark        = Color(0xFF9090B0);
  static const Color t3Dark        = Color(0xFF55556A);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF10B981);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color error    = Color(0xFFEF4444);
  static const Color info     = Color(0xFF3B82F6);

  // ── Member avatar palette ──────────────────────────────────────────────────
  static const List<Color> avatarColors = [
    Color(0xFF6366F1),
    Color(0xFF06C8A8),
    Color(0xFFFF5C72),
    Color(0xFFFBBF24),
    Color(0xFF8B5CF6),
    Color(0xFF0EA5E9),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];
}

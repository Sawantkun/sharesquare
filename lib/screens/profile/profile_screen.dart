import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/household_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t         = Theme.of(context);
    final isDark    = t.brightness == Brightness.dark;
    final auth      = context.watch<AuthProvider>();
    final household = context.watch<HouseholdProvider>();
    final tp        = context.watch<ThemeProvider>();
    final user      = auth.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: Icon(tp.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20),
                onPressed: tp.toggle,
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Profile hero ──────────────────────────────────────────
                _ProfileHero(user: user, isDark: isDark),
                const SizedBox(height: 28),

                // ── Household card ────────────────────────────────────────
                if (household.household != null) ...[
                  _SectionLabel(label: 'My Household'),
                  const SizedBox(height: 10),
                  _HouseholdCard(household: household, isDark: isDark),
                  const SizedBox(height: 24),
                ],

                // ── Appearance ────────────────────────────────────────────
                _SectionLabel(label: 'Appearance'),
                const SizedBox(height: 10),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ThemeTile(
                        icon: Icons.light_mode_rounded,
                        label: 'Light',
                        selected: tp.themeMode == ThemeMode.light,
                        onTap: () => tp.setThemeMode(ThemeMode.light),
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                      _ThemeTile(
                        icon: Icons.dark_mode_rounded,
                        label: 'Dark',
                        selected: tp.themeMode == ThemeMode.dark,
                        onTap: () => tp.setThemeMode(ThemeMode.dark),
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                      _ThemeTile(
                        icon: Icons.phone_android_rounded,
                        label: 'System',
                        selected: tp.themeMode == ThemeMode.system,
                        onTap: () => tp.setThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 24),

                // ── Settings ──────────────────────────────────────────────
                _SectionLabel(label: 'Settings'),
                const SizedBox(height: 10),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        iconColor: AppColors.gold,
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () {},
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                      _SettingsTile(
                        iconColor: AppColors.info,
                        icon: Icons.security_rounded,
                        label: 'Privacy & Security',
                        onTap: () {},
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                      _SettingsTile(
                        iconColor: AppColors.secondary,
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () {},
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                      _SettingsTile(
                        iconColor: AppColors.primary,
                        icon: Icons.info_outline_rounded,
                        label: 'About ShareSquare',
                        onTap: () => _showAbout(context),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 24),

                // ── Sign out ──────────────────────────────────────────────
                _SignOutButton(
                  onTap: () => _confirmSignOut(context, auth),
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'ShareSquare v1.0.0',
                    style: t.textTheme.bodySmall,
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Sign Out'),
        content: const Text('You\'ll need to sign back in to access your household.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut();
              context.go('/onboarding');
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ShareSquare',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 ShareSquare',
      children: [
        const SizedBox(height: 10),
        const Text('A modern roommate & flatshare management app.'),
      ],
    );
  }
}

// ── Profile hero ──────────────────────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  final dynamic user;
  final bool isDark;
  const _ProfileHero({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    if (user == null) return const SizedBox.shrink();

    return Center(
      child: Column(
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              gradient: AppColors.brand,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 24, offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.initials,
                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
              ),
            ),
          )
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 14),
          Text(user.name, style: t.textTheme.headlineSmall)
              .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 2),
          Text(user.email, style: t.textTheme.bodySmall)
              .animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.brand,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 10, offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, color: Colors.white, size: 12),
                SizedBox(width: 5),
                Text('Admin', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms, duration: 300.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }
}

// ── Household card ────────────────────────────────────────────────────────────
class _HouseholdCard extends StatelessWidget {
  final HouseholdProvider household;
  final bool isDark;
  const _HouseholdCard({required this.household, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final t  = Theme.of(context);
    final hh = household.household!;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.brand,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('🏠', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hh.name, style: t.textTheme.titleMedium),
                    Text(hh.address, style: t.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
          const SizedBox(height: 12),
          // Join code row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.key_rounded, size: 13, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Text(
                      hh.joinCode,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: hh.joinCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Code copied!'),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark2 : AppColors.bgLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                ),
              ),
              const Spacer(),
              Text(
                '${hh.memberCount} members',
                style: t.textTheme.bodySmall,
              ),
            ],
          ),
          if (household.members.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: household.members.map((m) =>
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: m.color.withValues(alpha: 0.14),
                    child: Text(m.initials, style: TextStyle(color: m.color, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      letterSpacing: 1.1, fontWeight: FontWeight.w700,
    ),
  );
}

// ── Theme tile ────────────────────────────────────────────────────────────────
class _ThemeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeTile({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Icon(icon, size: 20, color: selected ? AppColors.primary : null),
    title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    trailing: selected
        ? Container(
            width: 20, height: 20,
            decoration: BoxDecoration(gradient: AppColors.brand, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
          )
        : null,
    dense: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

// ── Settings tile ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.iconColor, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 17, color: iconColor),
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

// ── Sign out ──────────────────────────────────────────────────────────────────
class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: isDark ? 0.12 : 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withValues(alpha: isDark ? 0.28 : 0.18)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.accent, size: 18),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

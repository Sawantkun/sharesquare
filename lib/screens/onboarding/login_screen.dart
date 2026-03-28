import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/household_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/chore_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthProvider>().clearError();

    final ok = await context.read<AuthProvider>().signIn(
      _emailCtrl.text.trim(), _passCtrl.text,
    );
    if (ok && mounted) {
      _loadData();
      context.go('/home');
    }
  }

  void _loadData() {
    context.read<HouseholdProvider>().loadHousehold();
    context.read<ExpenseProvider>().loadExpenses();
    context.read<ChoreProvider>().loadChores();
    context.read<ChatProvider>().loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final t      = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── Brand mark ────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 68, height: 68,
                        decoration: BoxDecoration(
                          gradient: AppColors.brand,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.38),
                              blurRadius: 24, offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('⬡', style: TextStyle(fontSize: 32, color: Colors.white)),
                        ),
                      )
                          .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 12),
                      Text(
                        'ShareSquare',
                        style: t.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w800, letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      Text(
                        'Living together, beautifully',
                        style: t.textTheme.bodySmall,
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // ── Heading ───────────────────────────────────────────────
                Text('Welcome\nback', style: t.textTheme.displaySmall)
                    .animate().fadeIn(delay: 100.ms).slideY(begin: 0.12, end: 0),
                const SizedBox(height: 6),
                Text('Sign in to your household', style: t.textTheme.bodyMedium)
                    .animate().fadeIn(delay: 180.ms),
                const SizedBox(height: 28),

                // ── Error ─────────────────────────────────────────────────
                if (auth.errorMessage != null) ...[
                  _ErrorBanner(message: auth.errorMessage!),
                  const SizedBox(height: 16),
                ],

                // ── Fields ────────────────────────────────────────────────
                CustomTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passCtrl,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password required';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ).animate().fadeIn(delay: 270.ms).slideY(begin: 0.1, end: 0),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Forgot password?',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ).animate().fadeIn(delay: 310.ms),

                const SizedBox(height: 8),

                // ── CTA ───────────────────────────────────────────────────
                GradientButton(
                  label: 'Sign In',
                  onPressed: _submit,
                  isLoading: auth.isLoading,
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),
                _OrDivider(),
                const SizedBox(height: 16),

                OutlineGradientButton(
                  label: 'Create an account',
                  onPressed: () => context.go('/signup'),
                  icon: Icons.person_add_alt_1_rounded,
                ).animate().fadeIn(delay: 420.ms),

                const SizedBox(height: 28),
                Center(
                  child: Text(
                    'Demo: any email + 6-char password',
                    style: t.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.t3Dark : AppColors.t3Light,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ).animate().fadeIn(delay: 480.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 17),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 13))),
        ],
      ),
    ).animate().fadeIn().shake(hz: 3, offset: const Offset(4, 0));
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('or', style: Theme.of(context).textTheme.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

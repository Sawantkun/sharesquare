import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/gradient_button.dart';

class _Page {
  final String emoji;
  final String headline;
  final String sub;
  final Gradient gradient;
  const _Page(this.emoji, this.headline, this.sub, this.gradient);
}

const _pages = [
  _Page('🏠', 'Your home,\norganised', 'Track expenses, chores and bills for your shared home — all in one beautifully simple place.', AppColors.brand),
  _Page('💸', 'Split fairly,\nsettle easily', 'Record shared costs in seconds. See exactly who owes what and settle up with one tap.', AppColors.teal),
  _Page('✅', 'Chores,\non rotation', 'Rotating schedules and nudges keep everyone pulling their weight — no nagging required.', AppColors.violet),
  _Page('💬', 'Stay in\nthe loop', 'Housemate chat, polls, and shared notes keep everyone connected and on the same page.', AppColors.coral),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(duration: 380.ms, curve: Curves.easeInOut);
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _PageView(page: _pages[i]),
          ),

          // Bottom controls
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24, 32, 24, MediaQuery.of(context).padding.bottom + 28,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: 280.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),

                  // Buttons
                  Row(
                    children: [
                      // Skip / Back
                      SizedBox(
                        width: 90,
                        height: 50,
                        child: TextButton(
                          onPressed: _page == 0
                              ? () => context.go('/login')
                              : () => _ctrl.previousPage(duration: 380.ms, curve: Curves.easeInOut),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(_page == 0 ? 'Skip' : 'Back',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Next / Get started
                      Expanded(
                        child: GradientButton(
                          label: _page == _pages.length - 1 ? 'Get Started' : 'Next',
                          onPressed: _next,
                          gradient: const LinearGradient(
                            colors: [Colors.white24, Colors.white30],
                          ),
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(foregroundColor: Colors.white54),
                    child: const Text('Already have an account? Sign in',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  final _Page page;
  const _PageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: page.gradient),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Illustration circle
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(page.emoji, style: const TextStyle(fontSize: 88)),
              ),
            )
                .animate()
                .scale(duration: 550.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 350.ms),
            const SizedBox(height: 44),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                page.headline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 180.ms, duration: 450.ms)
                .slideY(begin: 0.15, end: 0),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                page.sub,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.78),
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 450.ms)
                .slideY(begin: 0.1, end: 0),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

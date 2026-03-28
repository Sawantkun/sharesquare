import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../home/home_screen.dart';
import '../expenses/expenses_screen.dart';
import '../chores/chores_screen.dart';
import '../messages/messages_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  late int _current;

  final _screens = const [
    HomeScreen(),
    ExpensesScreen(),
    ChoresScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  void _go(int i) {
    if (_current == i) return;
    setState(() => _current = i);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = context.watch<ChatProvider>().unreadCount;

    return Scaffold(
      body: IndexedStack(index: _current, children: _screens),
      bottomNavigationBar: _FloatingNavBar(
        current: _current,
        unread: unread,
        isDark: isDark,
        onTap: _go,
      ),
    );
  }
}

// ── Nav item data ─────────────────────────────────────────────────────────────
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData(this.icon, this.activeIcon, this.label);
}

const _items = [
  _NavItemData(Icons.home_outlined,         Icons.home_rounded,         'Home'),
  _NavItemData(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Expenses'),
  _NavItemData(Icons.checklist_outlined,    Icons.checklist_rounded,    'Chores'),
  _NavItemData(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'),
  _NavItemData(Icons.person_outline_rounded, Icons.person_rounded,      'Profile'),
];

// ── Floating nav bar ──────────────────────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final int current;
  final int unread;
  final bool isDark;
  final void Function(int) onTap;

  const _FloatingNavBar({
    required this.current,
    required this.unread,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg   = isDark ? AppColors.cardDark  : AppColors.cardLight;
    final bdr  = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: bdr, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item  = _items[i];
              final active = i == current;
              final hasBadge = i == 3 && unread > 0;

              return Expanded(
                child: _NavTile(
                  icon:       item.icon,
                  activeIcon: item.activeIcon,
                  label:      item.label,
                  active:     active,
                  badge:      hasBadge ? '$unread' : null,
                  onTap:      () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final String? badge;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badge,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: 220.ms);
    _scale = Tween(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(_NavTile old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _ctrl.forward().then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with pill background
            AnimatedContainer(
              duration: 220.ms,
              curve: Curves.easeInOut,
              width: widget.active ? 52 : 40,
              height: 32,
              decoration: BoxDecoration(
                color: widget.active
                    ? AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Icon(
                      widget.active ? widget.activeIcon : widget.icon,
                      size: 22,
                      color: widget.active ? AppColors.primary : AppColors.t3Light.withValues(alpha: isDark ? 0.8 : 1.0),
                    ),
                  ),
                  if (widget.badge != null)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: AppColors.coral,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.cardDark : AppColors.cardLight,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          widget.badge!,
                          style: const TextStyle(
                            color: Colors.white, fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ).animate().scale(duration: 250.ms, curve: Curves.elasticOut),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: 200.ms,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: widget.active ? FontWeight.w600 : FontWeight.w400,
                color: widget.active ? AppColors.primary : (isDark ? AppColors.t3Dark : AppColors.t3Light),
                letterSpacing: 0.1,
              ),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}

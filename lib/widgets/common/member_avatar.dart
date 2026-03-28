import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class MemberAvatar extends StatelessWidget {
  final UserModel user;
  final double size;
  final bool showBorder;
  final bool showName;
  final VoidCallback? onTap;

  const MemberAvatar({
    super.key,
    required this.user,
    this.size = 40,
    this.showBorder = false,
    this.showName = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: user.color.withValues(alpha: 0.15),
          border: showBorder
              ? Border.all(color: user.color, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            user.initials,
            style: TextStyle(
              color: user.color,
              fontSize: size * 0.36,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );

    if (!showName) return avatar;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        const SizedBox(height: 4),
        Text(
          user.name.split(' ').first,
          style: Theme.of(context).textTheme.labelSmall,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class MemberAvatarStack extends StatelessWidget {
  final List<UserModel> users;
  final double size;
  final int maxVisible;

  const MemberAvatarStack({
    super.key,
    required this.users,
    this.size = 32,
    this.maxVisible = 4,
  });

  @override
  Widget build(BuildContext context) {
    final visible = users.take(maxVisible).toList();
    final extra = users.length - maxVisible;

    return SizedBox(
      width: visible.length * (size * 0.7) + size * 0.3,
      height: size,
      child: Stack(
        children: [
          ...visible.asMap().entries.map((entry) {
            return Positioned(
              left: entry.key * (size * 0.7),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: MemberAvatar(user: entry.value, size: size),
              ),
            );
          }),
          if (extra > 0)
            Positioned(
              left: visible.length * (size * 0.7),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

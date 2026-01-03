import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class AvatarView extends StatelessWidget {
  final int? avatarId;
  final double size;

  const AvatarView({
    super.key,
    required this.avatarId,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final int id = avatarId ?? 0;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.surface,
      backgroundImage: AssetImage(
        'assets/avatars/avatar_$id.png',
      ),
    );
  }
}
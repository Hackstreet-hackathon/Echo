import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// PWD badge indicator for accessibility
class PwdBadge extends StatelessWidget {
  const PwdBadge({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Person with disability priority',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.pwdBadge.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.pwdBadge, width: 1.5),
        ),
        child: Icon(
          Icons.accessible,
          size: size * 0.6,
          color: AppColors.pwdBadge,
        ),
      ),
    );
  }
}

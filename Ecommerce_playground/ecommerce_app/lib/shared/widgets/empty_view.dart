import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.heading, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

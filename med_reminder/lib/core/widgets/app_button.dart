import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width = double.infinity,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _backgroundColor();
    final effectiveTextColor = _textColor();

    Widget content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: effectiveTextColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: effectiveTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onPressed,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: _border(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: content,
          ),
        ),
      ),
    );
  }

  Color _backgroundColor() {
    if (onPressed == null) return AppColors.border;
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return AppColors.primaryLight;
      case AppButtonVariant.danger:
        return AppColors.dangerLight;
      case AppButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _textColor() {
    if (onPressed == null) return AppColors.textMuted;
    switch (variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.secondary:
        return AppColors.primary;
      case AppButtonVariant.danger:
        return AppColors.danger;
      case AppButtonVariant.ghost:
        return AppColors.textPrimary;
    }
  }

  Border? _border() {
    switch (variant) {
      case AppButtonVariant.secondary:
        return Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1);
      case AppButtonVariant.ghost:
        return Border.all(color: AppColors.border, width: 1);
      default:
        return null;
    }
  }
}

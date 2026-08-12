import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.rating,
    required this.error,
  });

  final Color background;
  final Color surface;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color border;
  final Color accent;
  final Color onAccent;
  final Color rating;
  final Color error;

  static const AppPalette light = AppPalette(
    background: AppColors.background,
    surface: AppColors.surface,
    ink: AppColors.ink,
    inkSoft: AppColors.inkSoft,
    muted: AppColors.muted,
    border: AppColors.border,
    accent: AppColors.accent,
    onAccent: AppColors.onAccent,
    rating: AppColors.rating,
    error: AppColors.error,
  );

  static const AppPalette dark = AppPalette(
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    ink: AppColors.inkDark,
    inkSoft: AppColors.inkSoftDark,
    muted: AppColors.mutedDark,
    border: AppColors.borderDark,
    accent: AppColors.accentDark,
    onAccent: AppColors.onAccentDark,
    rating: AppColors.ratingDark,
    error: AppColors.errorDark,
  );

  static AppPalette of(BuildContext context) {
    return Theme.of(context).extension<AppPalette>()!;
  }

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? ink,
    Color? inkSoft,
    Color? muted,
    Color? border,
    Color? accent,
    Color? onAccent,
    Color? rating,
    Color? error,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      rating: rating ?? this.rating,
      error: error ?? this.error,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      rating: Color.lerp(rating, other.rating, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

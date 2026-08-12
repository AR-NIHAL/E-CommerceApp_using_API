import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppTextStyles {
  static const String fontFamily = 'Inter';

  static AppTextTheme of(BuildContext context) {
    return AppTextTheme(AppPalette.of(context));
  }

  static AppTextTheme forPalette(AppPalette palette) {
    return AppTextTheme(palette);
  }
}

class AppTextTheme {
  AppTextTheme(this._palette);

  final AppPalette _palette;

  TextStyle get display => TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
        color: _palette.ink,
      );

  TextStyle get title => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: _palette.ink,
      );

  TextStyle get heading => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: _palette.ink,
      );

  TextStyle get body => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: _palette.inkSoft,
      );

  TextStyle get label => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: _palette.muted,
      );

  TextStyle get price => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: _palette.ink,
      );
}

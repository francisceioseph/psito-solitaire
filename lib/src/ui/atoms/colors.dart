import 'package:flutter/material.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

abstract final class PsitoColors {
  static const felt = Color(0xFF3B6478);
  static const feltGlow = Color(0xFF4A7A90);
  static const feltDark = Color(0xFF2C4E60);
  static const feltLight = Color(0xFF86A9BC);
  static const cream = Color(0xFFF6EED6);
  static const black = Color(0xFF3B3842);
  static const edge = Color(0xFFAE9A74);
  static const accent = Color(0xFFFFC107);
  static const onFelt = Color(0xFFF3EFE0);
  static const onFeltMuted = Color(0xFFA9C2D0);
  static const barTop = Color(0xFF2A4A5C);
  static const barBottom = Color(0xFF213C4C);
}

/// The blue felt of the table, for the shared widgets.
const solitairePalette = GamePalette(
  felt: PsitoColors.felt,
  feltGlow: PsitoColors.feltGlow,
  feltDark: PsitoColors.feltDark,
  feltLight: PsitoColors.feltLight,
  barTop: PsitoColors.barTop,
  barBottom: PsitoColors.barBottom,
  onFelt: PsitoColors.onFelt,
  onFeltMuted: PsitoColors.onFeltMuted,
  cream: PsitoColors.cream,
  ink: PsitoColors.black,
);

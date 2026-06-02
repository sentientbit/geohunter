/// Shared dark Lovecraftian design tokens for GeoHunter detail screens.
///
/// Import this file in any detail screen to get a consistent dark atmosphere:
///   import '../../shared/app_theme.dart';
library app_theme;

import 'package:flutter/material.dart';

// ── Palette ────────────────────────────────────────────────────────────────────

/// Ultra-dark card background — nearly black, slightly transparent.
const kCardBg = Color(0xcc050505);

/// Silver-white — primary body text.
const kSilver = Color(0xffC8C8D0);

/// Dimmer silver — section labels, secondary text.
const kSilverDim = Color(0xff9898A8);

/// Warm gold — accent for research, forge, and reward UI.
const kGold = Color(0xffe6a04e);

// ── Text styles ────────────────────────────────────────────────────────────────

/// Section label: silverDim, uppercase, generous letter-spacing.
const kSectionLabel = TextStyle(
  color: kSilverDim,
  fontSize: 12,
  letterSpacing: 3.5,
  fontFamily: 'Open Sans',
);

// ── Card decoration ────────────────────────────────────────────────────────────

/// Dark card with a colour-tinted border and soft ambient glow.
///
/// [accent]    — colour used for border tint and glow (typically rarity colour
///               or [kGold] for research screens).
/// [radius]    — corner radius (default 12, use 6 for item-detail cards).
/// [glowAlpha] — opacity of the ambient glow shadow (0–1).
/// [glowBlur]  — blur radius of the ambient glow.
BoxDecoration kCardDecoration(
  Color accent, {
  double radius = 12,
  double glowAlpha = 0.07,
  double glowBlur = 16,
}) =>
    BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: accent.withValues(alpha: 0.22), width: 0.8),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: glowAlpha),
          blurRadius: glowBlur,
          spreadRadius: 1,
        ),
      ],
    );

// ── Divider ────────────────────────────────────────────────────────────────────

/// Thin ornamental divider:  ─── ✦ ───
///
/// Drop this between major sections inside a [Column].
Widget kEldritchDivider(Color accent) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(children: [
        Expanded(
            child: Divider(
                color: accent.withValues(alpha: 0.35), thickness: 0.6)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('✦',
              style: TextStyle(
                  color: accent.withValues(alpha: 0.7), fontSize: 11)),
        ),
        Expanded(
            child: Divider(
                color: accent.withValues(alpha: 0.35), thickness: 0.6)),
      ]),
    );

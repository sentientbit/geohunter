/// Shared dark Lovecraftian design tokens for GeoHunter detail screens.
///
/// Import this file in any detail screen to get a consistent dark atmosphere:
///   import '../../shared/app_theme.dart';
library app_theme;

import 'package:flutter/material.dart';

// ── Palette ────────────────────────────────────────────────────────────────────

/// Dark card background — semi-transparent so the scene texture shows through.
const kCardBg = Color(0xaa0e0c08);

/// Silver-white — primary body text.
const kSilver = Color(0xffC8C8D0);

/// Dimmer silver — section labels, secondary text.
const kSilverDim = Color(0xffB8B8C4);

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

// ── Primary action button ──────────────────────────────────────────────────────
/// Dark semi-transparent fill, gold border, ambient gold glow.
/// Tapping brightens the fill so the press is clearly felt.
///
/// Usage:
///   kStoneButton(onTap: _doSomething, child: Text('Craft', style: ...))
Widget kStoneButton({
  required VoidCallback? onTap,
  required Widget child,
  EdgeInsetsGeometry padding =
      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
  double radius = 10,
}) =>
    _KStoneButton(
      onTap: onTap,
      padding: padding,
      radius: radius,
      child: child,
    );

class _KStoneButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const _KStoneButton({
    required this.onTap,
    required this.child,
    required this.padding,
    required this.radius,
  });

  @override
  State<_KStoneButton> createState() => _KStoneButtonState();
}

class _KStoneButtonState extends State<_KStoneButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap?.call(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: Opacity(
        opacity: widget.onTap == null ? 0.38 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: double.infinity,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            // Fill brightens slightly when pressed.
            color: _pressed
                ? const Color(0xff3a2810)
                : const Color(0xcc1a1008),
            border: Border.all(
              color: _pressed
                  ? const Color(0xffe6a04e)           // full gold when pressed
                  : const Color(0xaae6a04e),          // 67% gold at rest
              width: 1.2,
            ),
            boxShadow: _pressed
                ? []                                  // flush with surface when pressed
                : [
                    // Ambient gold glow — makes the button readable on any bg.
                    BoxShadow(
                      color: const Color(0xffe6a04e).withValues(alpha: 0.18),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                    // Drop shadow for lift.
                    const BoxShadow(
                      color: Color(0xaa000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

// ── Compass loader ─────────────────────────────────────────────────────────────
/// Replaces CircularProgressIndicator across all screens.
/// Usage: Center(child: kCompassLoader) or just kCompassLoader inside a Center.
Widget kCompassLoader({double size = 150}) => Image.asset(
      'assets/images/compass.gif',
      width: size,
      height: size,
    );


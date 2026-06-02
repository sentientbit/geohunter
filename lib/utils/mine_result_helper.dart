import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_localizations.dart';
import '../models/mine_detail_response.dart';
import '../providers/blueprint_pages_provider.dart';
import '../providers/research_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_dialog.dart';

/// Shared post-visit logic for every screen that can trigger a mine visit.
///
/// Both the Map screen (proximity) and the Places screen (remote/paid) call
/// the same API endpoint and receive the same [MineDetailResponse].  All
/// post-call behaviour — building the loot image grid, invalidating providers,
/// and showing the Congrats dialog — is identical.  This helper owns that
/// shared logic so it can't drift between the two call sites.
///
/// Usage:
///   // After a successful getMine() / getMineRemote() call:
///   MineResultHelper.handle(
///     context, ref,
///     mineId:  mineId,
///     result:  result,
///     comment: mineComment,        // optional subtitle in dialog
///     delayed: true,               // map screen waits 1 s; places screen doesn't
///     onDismiss: loadPlaces,        // places screen refreshes list on dismiss
///   );
abstract class MineResultHelper {
  // ── public API ──────────────────────────────────────────────────────────────

  /// Invalidates Riverpod providers and shows the Congrats dialog.
  ///
  /// [delayed]: if true, waits 1 second before showing the dialog (the map
  ///   screen needs this gap so the map animation settles first).
  /// [onDismiss]: optional callback fired when the user taps "Okay".
  static void handle(
    BuildContext context,
    WidgetRef ref, {
    required int mineId,
    required MineDetailResponse result,
    String comment = '',
    bool delayed = false,
    VoidCallback? onDismiss,
  }) {
    _invalidateProviders(ref, result);

    final images = _buildImages(result);

    if (delayed) {
      Timer(const Duration(seconds: 1), () {
        if (context.mounted) _showDialog(context, mineId, comment, images, onDismiss);
      });
    } else {
      if (context.mounted) _showDialog(context, mineId, comment, images, onDismiss);
    }
  }

  // ── private ─────────────────────────────────────────────────────────────────

  /// Invalidates the providers that may have changed as a result of the visit.
  ///
  /// userProvider        — coins and XP always change.
  /// blueprintPagesProvider
  /// researchProvider    — only when pages were dropped or manuscripts converted;
  ///                        avoids an unnecessary API round-trip on regular mines.
  static void _invalidateProviders(WidgetRef ref, MineDetailResponse result) {
    ref.invalidate(userProvider);

    if (result.blueprints.isNotEmpty || result.manuscriptsConverted > 0) {
      ref.invalidate(blueprintPagesProvider);
      ref.invalidate(researchProvider);
    }
  }

  /// Builds the ordered loot image grid: items first, then materials, then
  /// blueprint pages (same order as the server populates the arrays).
  static List<Image> _buildImages(MineDetailResponse result) {
    final images = <Image>[];

    for (final item in result.items) {
      if (item.img.isNotEmpty) {
        images.add(Image.asset('assets/images/items/${item.img}'));
      }
    }
    for (final mat in result.materials) {
      if (mat.img.isNotEmpty) {
        images.add(Image.asset('assets/images/materials/${mat.img}'));
      }
    }
    for (final bp in result.blueprints) {
      if (bp.img.isNotEmpty && bp.img != 'nothing.png') {
        images.add(Image.asset('assets/images/blueprints/${bp.img}'));
      }
    }

    return images;
  }

  static void _showDialog(
    BuildContext context,
    int mineId,
    String comment,
    List<Image> images,
    VoidCallback? onDismiss,
  ) {
    final loc = AppLocalizations.of(context);
    final title       = loc?.translate('congrats')         ?? 'Congrats';
    final foundPrefix = loc?.translate('you_found_point')  ?? 'You mined successfully Point';
    final description = comment.isNotEmpty
        ? '$foundPrefix $mineId, $comment'
        : '$foundPrefix $mineId';

    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        title:       title,
        description: description,
        buttonText:  'Okay',
        images:      images,
        callback:    onDismiss ?? () {},
      ),
    );
  }
}

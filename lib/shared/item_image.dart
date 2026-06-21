import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';

/// Resolves an item's `img` value to an [ImageProvider].
///
/// Item art is migrating from bundled assets to server-hosted WebP delivered
/// over the network, so the catalogue can grow without an app release. This
/// resolver accepts every shape that can appear during (and after) the rollout:
///
///   - absolute URL            → network, used as-is
///   - host-relative path "/…" → network, prefixed with the API host
///                               (same convention as avatars and journal art)
///   - bare filename (legacy)  → bundled asset  assets/images/items/<img>
///   - empty                   → bundled "nothing.png" sentinel
///
/// Plugs straight into existing `Image(image: …)` / `DecorationImage(image: …)`
/// call sites, so each screen keeps its own sizing, fit and errorBuilder. Where
/// a site supplies an `errorBuilder`, it still fires on a network 404 — letting
/// the screen fall back to its own placeholder.
ImageProvider itemImageProvider(String img) {
  if (img.isEmpty) {
    return const AssetImage('assets/images/items/nothing.png');
  }
  if (img.startsWith('http://') || img.startsWith('https://')) {
    return CachedNetworkImageProvider(img);
  }
  if (img.startsWith('/')) {
    return CachedNetworkImageProvider(
        'https://${GlobalConstants.apiHostUrl}$img');
  }
  return AssetImage('assets/images/items/$img');
}

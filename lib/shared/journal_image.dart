import 'constants.dart';

/// Resolves a Journal `img` value to a loadable URL, or null if there's no art
/// to show yet (caller falls back to a themed icon).
///
/// Journal art is server-hosted (it grows arc-by-arc without app releases), so
/// we render it over the network rather than bundling it. Accepted shapes:
///   - absolute URL            → used as-is
///   - host-relative path "/…" → prefixed with the API host (avatar convention)
///   - bare filename           → null (no canonical path yet; show the icon)
///
/// Once the backend returns host-relative paths (e.g. "/img/journal/x.webp"),
/// this lights up automatically with no further client change.
String? journalImageUrl(String img) {
  if (img.isEmpty) return null;
  if (img.startsWith('http://') || img.startsWith('https://')) return img;
  if (img.startsWith('/')) return 'https://${GlobalConstants.apiHostUrl}$img';
  return null;
}

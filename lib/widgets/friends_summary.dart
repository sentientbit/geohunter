import 'package:flutter/material.dart';
import 'package:geohunter/fonts/rpg_awesome_icons.dart';

import '../models/friends.dart';
import '../screens/friendship/paldetail.dart';
import '../shared/app_theme.dart';
import '../shared/constants.dart';

// ── Edge colour — amber orange across the board ──────────────────────────────
Color _edgeColor(int level, bool hasRaven) => const Color(0xffe6a04e);

// Reuse the same L-bracket corner engravings as the forge material slots
Widget _cornerEngravings(Color color) {
  const len = 9.0;
  const thick = 1.5;
  final c = color.withValues(alpha: 0.18);
  Widget h() => Container(width: len, height: thick, color: c);
  Widget v() => Container(width: thick, height: len, color: c);
  return Stack(children: [
    Positioned(top: 0, left: 0,  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [v(), h()])),
    Positioned(top: 0, right: 0, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [h(), v()])),
    Positioned(bottom: 0, left: 0,  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [v(), h()])),
    Positioned(bottom: 0, right: 0, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [h(), v()])),
  ]);
}

class FriendsSummary extends StatelessWidget {
  final Friend friend;
  final bool hasRaven;
  final bool horizontal;

  FriendsSummary(this.friend, this.hasRaven, {this.horizontal = true});
  FriendsSummary.vertical(this.friend) : hasRaven = false, horizontal = false;

  @override
  Widget build(BuildContext context) {
    final int level  = expToLevel(friend.xp);
    final Color edge = _edgeColor(level, hasRaven);
    final String avatarUrl =
        'https://${GlobalConstants.apiHostUrl}${friend.thumbnail}';
    final String? status = (friend.status ?? '').isEmpty || friend.status == 'null'
        ? null
        : friend.status;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PalDetailPage(friend: friend)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        // ── Outer shell — gradient acts as the bevel border ──────────────
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment(-1.0, -1.0), // true top-left corner
            end: Alignment(1.0, 1.0),     // true bottom-right corner
            stops: [0.0, 0.25, 0.65, 1.0],
            colors: [
              Color(0xff3d2a0e), // darker warm highlight — top-left
              Color(0xff100a04), // recedes quickly
              Color(0xff080503), // deep shadow
              Color(0xff030201), // near-black bottom-right
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.50),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.5),
          child: Container(
          // 1.5px margin exposes just the gradient as the "border"
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.5),
            image: const DecorationImage(
              image: AssetImage('assets/images/card_stone.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color(0x73000000), // ~45% dark overlay
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
          children: [
            // Corner engravings
            Positioned.fill(child: _cornerEngravings(edge)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // ── Avatar + level badge ─────────────────────────────────
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: edge.withValues(alpha: 0.65), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: edge.withValues(alpha: 0.22),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'planet-hero-${friend.id}',
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(avatarUrl),
                            backgroundColor: Colors.black,
                          ),
                        ),
                      ),
                      // Level badge — bottom-centre of avatar
                      Positioned(
                        bottom: -4,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: edge.withValues(alpha: 0.70), width: 1),
                            ),
                            child: Text(
                              '$level',
                              style: TextStyle(
                                color: edge,
                                fontSize: 10,
                                fontFamily: 'Cormorant SC',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 14),

                  // ── Text block ───────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          friend.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kSilver,
                            fontSize: 18,
                            fontFamily: 'Cormorant SC',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.trending_up,
                                size: 13,
                                color: edge.withValues(alpha: 0.85)),
                            const SizedBox(width: 3),
                            Text(
                              'Lv $level',
                              style: TextStyle(
                                color: edge.withValues(alpha: 0.85),
                                fontSize: 13,
                                fontFamily: 'Cormorant SC',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (hasRaven) ...[
                              const SizedBox(width: 8),
                              Icon(RPGAwesome.raven, color: edge, size: 14),
                            ],
                          ],
                        ),
                        if (status != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kSilverDim,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Chevron ──────────────────────────────────────────────
                  Icon(Icons.chevron_right,
                      color: edge.withValues(alpha: 0.50), size: 22),
                ],
              ),
            ),
          ],
        ),
        ),  // inner stone container
        ),  // ClipRRect
      ),    // outer gradient border container
    );
  }
}

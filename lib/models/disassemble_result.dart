/// Result of POST /api/blueprint/disassemble { blueprint_id, qty }.
class DisassembleResult {
  /// Manuscripts gained from this disassembly action.
  final int manuscriptsGained;

  /// Player's new total manuscript count after the action.
  final int manuscriptsTotal;

  /// How many volumes of this blueprint the player still holds.
  final int volumesRemaining;

  const DisassembleResult({
    required this.manuscriptsGained,
    required this.manuscriptsTotal,
    required this.volumesRemaining,
  });

  factory DisassembleResult.fromJson(Map<String, dynamic> json) {
    return DisassembleResult(
      manuscriptsGained:
          int.tryParse((json['manuscripts_gained'] ?? 0).toString()) ?? 0,
      manuscriptsTotal:
          int.tryParse((json['manuscripts_total'] ?? 0).toString()) ?? 0,
      volumesRemaining:
          int.tryParse((json['volumes_remaining'] ?? 0).toString()) ?? 0,
    );
  }
}

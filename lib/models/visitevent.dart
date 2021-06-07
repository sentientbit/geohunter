///
class VisitEvent {
  ///
  VisitEvent(int result, String mType, int mId)
      : assert(mType != ""),
        outcome = result,
        icoProperty = mType,
        mineId = mId;

  /// victory: 1, nothing: 0, defeat: -1
  int outcome = 0;

  ///
  String icoProperty = "0";

  /// the id of the mine
  int mineId = 0;

  /// Override toString to have a beautiful log
  @override
  String toString() {
    return 'VisitEvent({outcome: $outcome, icoProperty: $icoProperty, mineId: $mineId})';
  }
}

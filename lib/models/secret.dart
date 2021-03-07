///
class Secret {
  ///
  final String enqKey;

  ///
  Secret({this.enqKey = ""});

  ///
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return Secret(enqKey: jsonMap["enq_key"]);
  }
}

import 'dart:convert' as convert;
import 'package:flutter/services.dart' show rootBundle;

///
class Secret {
  ///
  String enqKey = "";

  ///
  Secret({this.enqKey = ""});

  ///
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return Secret(enqKey: jsonMap["enq_key"]);
  }
}

///
class SecretLoader {
  ///
  String secretPath = "";

  ///
  SecretLoader({this.secretPath = ""});

  ///
  Future<Secret> load() {
    return rootBundle.loadStructuredData<Secret>(secretPath, (jsonStr) async {
      final secret = Secret.fromJson(convert.json.decode(jsonStr));
      return secret;
    });
  }
}

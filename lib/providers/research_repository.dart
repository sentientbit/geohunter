import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/research_response.dart';
import 'api_provider.dart';

/// Fetches the player's research techs and blueprints from the server.
class ResearchRepository {
  final ApiProvider _api = ApiProvider();

  Future<ResearchResponse> getResearch() async {
    final response = await _api.get('/research');
    return ResearchResponse.fromJson(response);
  }
}

final researchRepositoryProvider =
    Provider<ResearchRepository>((ref) => ResearchRepository());

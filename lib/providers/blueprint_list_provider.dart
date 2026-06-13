import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/blueprint.dart';
import '../models/app_error.dart';
import 'api_provider.dart';

/// Fetches the player's blueprint inventory (POST /inventory, types=[17]).
///
/// Both the forge blueprint selector and the inventory blueprints list watch
/// this provider so the fetch logic lives in exactly one place.
///
/// autoDispose: the list is only needed while a picker or inventory screen is
/// open — dispose when all listeners detach.
final blueprintListProvider =
    FutureProvider.autoDispose<List<Blueprint>>((ref) async {
  try {
    final response =
        await ApiProvider().post('/inventory', {'types': [17]});
    if (!response.containsKey('blueprints')) return [];
    return (response['blueprints'] as List)
        .map((e) => Blueprint.fromJson(e as Map<String, dynamic>))
        .toList();
  } on AppError {
    rethrow;
  } catch (e) {
    throw Exception('blueprintListProvider: $e');
  }
});

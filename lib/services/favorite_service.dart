import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal_detail.dart';
import '../models/meal_summary.dart';

class FavoriteService {
  static const boxName = 'favorite_meals';

  Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  ValueListenable<Box<dynamic>> get listenable => _box.listenable();

  List<MealSummary> getAllFavorites() {
    return _box.values
        .whereType<Map<dynamic, dynamic>>()
        .map(MealSummary.fromFavoriteMap)
        .where((meal) => meal.id.isNotEmpty)
        .toList();
  }

  bool isFavorite(String mealId) {
    return _box.containsKey(mealId);
  }

  Future<void> add(MealDetail meal) async {
    await _box.put(meal.id, meal.toFavoriteMap());
  }

  Future<void> remove(String mealId) async {
    await _box.delete(mealId);
  }
}

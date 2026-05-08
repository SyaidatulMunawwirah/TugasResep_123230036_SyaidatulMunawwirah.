import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal_detail.dart';
import '../models/meal_summary.dart';

class MealApiService {
  static const _host = 'www.themealdb.com';
  static const _basePath = '/api/json/v1/1';

  Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final uri = Uri.https(_host, '$_basePath/filter.php', {'c': category});
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil daftar resep.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final meals = data['meals'] as List<dynamic>? ?? [];

    return meals
        .map((meal) => MealSummary.fromJson(meal as Map<String, dynamic>))
        .toList();
  }

  Future<MealDetail> fetchMealDetail(String id) async {
    final uri = Uri.https(_host, '$_basePath/lookup.php', {'i': id});
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil detail resep.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final meals = data['meals'] as List<dynamic>?;

    if (meals == null || meals.isEmpty) {
      throw Exception('Detail resep tidak ditemukan.');
    }

    return MealDetail.fromJson(meals.first as Map<String, dynamic>);
  }
}

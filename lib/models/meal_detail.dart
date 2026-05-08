class IngredientItem {
  const IngredientItem({required this.ingredient, required this.measure});

  final String ingredient;
  final String measure;
}

class MealDetail {
  const MealDetail({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.category,
    required this.area,
    required this.instructions,
    required this.ingredients,
  });

  final String id;
  final String name;
  final String thumbnail;
  final String category;
  final String area;
  final String instructions;
  final List<IngredientItem> ingredients;

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final ingredients = <IngredientItem>[];

    for (var index = 1; index <= 20; index++) {
      final ingredient = (json['strIngredient$index'] as String? ?? '').trim();
      final measure = (json['strMeasure$index'] as String? ?? '').trim();

      if (ingredient.isNotEmpty) {
        ingredients.add(
          IngredientItem(
            ingredient: ingredient,
            measure: measure.isEmpty ? '-' : measure,
          ),
        );
      }
    }

    return MealDetail(
      id: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? 'Tanpa Nama',
      thumbnail: json['strMealThumb'] as String? ?? '',
      category: json['strCategory'] as String? ?? '-',
      area: json['strArea'] as String? ?? '-',
      instructions: json['strInstructions'] as String? ?? '-',
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toFavoriteMap() {
    return {'idMeal': id, 'strMeal': name, 'strMealThumb': thumbnail};
  }
}

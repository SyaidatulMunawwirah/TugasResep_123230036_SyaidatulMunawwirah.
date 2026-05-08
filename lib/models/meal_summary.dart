class MealSummary {
  const MealSummary({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  final String id;
  final String name;
  final String thumbnail;

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? 'Tanpa Nama',
      thumbnail: json['strMealThumb'] as String? ?? '',
    );
  }

  factory MealSummary.fromFavoriteMap(Map<dynamic, dynamic> map) {
    return MealSummary(
      id: map['idMeal'] as String? ?? '',
      name: map['strMeal'] as String? ?? 'Tanpa Nama',
      thumbnail: map['strMealThumb'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFavoriteMap() {
    return {'idMeal': id, 'strMeal': name, 'strMealThumb': thumbnail};
  }
}

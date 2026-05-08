import 'package:flutter/material.dart';

import '../models/meal_summary.dart';
import '../services/meal_api_service.dart';
import '../widgets/meal_card.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _apiService = MealApiService();
  final _categories = const [
    'Seafood',
    'Chicken',
    'Dessert',
    'Beef',
    'Vegetarian',
    'Pasta',
  ];

  late Future<List<MealSummary>> _mealsFuture;
  String _selectedCategory = 'Seafood';

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  void _loadMeals() {
    _mealsFuture = _apiService.fetchMealsByCategory(_selectedCategory);
  }

  Future<void> _refreshMeals() async {
    setState(_loadMeals);
    try {
      await _mealsFuture;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  void _openDetail(MealSummary meal) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DetailPage(mealId: meal.id)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CategorySelector(
          categories: _categories,
          selectedCategory: _selectedCategory,
          onChanged: (category) {
            setState(() {
              _selectedCategory = category;
              _loadMeals();
            });
          },
        ),
        Expanded(
          child: FutureBuilder<List<MealSummary>>(
            future: _mealsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _ErrorState(onRetry: _refreshMeals);
              }

              final meals = snapshot.data ?? [];

              if (meals.isEmpty) {
                return const _EmptyState(
                  message: 'Belum ada resep untuk kategori ini.',
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshMeals,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 700 ? 4 : 2;

                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: meals.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return MealCard(
                          meal: meal,
                          onTap: () => _openDetail(meal),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Row(
          children: [
            const Icon(Icons.tune, color: Color(0xFF008577)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              size: 56,
              color: Colors.black45,
            ),
            const SizedBox(height: 12),
            const Text(
              'Resep belum berhasil dimuat.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.ramen_dining_outlined, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

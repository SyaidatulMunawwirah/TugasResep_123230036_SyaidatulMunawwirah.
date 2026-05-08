import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/meal_detail.dart';
import '../services/favorite_service.dart';
import '../services/meal_api_service.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.mealId});

  final String mealId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _apiService = MealApiService();
  final _favoriteService = FavoriteService();

  late Future<MealDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _apiService.fetchMealDetail(widget.mealId);
  }

  Future<void> _refreshDetail() async {
    setState(() {
      _detailFuture = _apiService.fetchMealDetail(widget.mealId);
    });

    try {
      await _detailFuture;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _toggleFavorite(MealDetail meal, bool isFavorite) async {
    if (isFavorite) {
      await _favoriteService.remove(meal.id);
    } else {
      await _favoriteService.add(meal);
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '${meal.name} dihapus dari favorit.'
              : '${meal.name} ditambahkan ke favorit.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Resep')),
      body: FutureBuilder<MealDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _DetailErrorState(onRetry: _refreshDetail);
          }

          final meal = snapshot.data;

          if (meal == null) {
            return const Center(child: Text('Detail resep tidak ditemukan.'));
          }

          return RefreshIndicator(
            onRefresh: _refreshDetail,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    meal.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE5ECE9),
                        child: const Icon(Icons.restaurant_menu, size: 64),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.category_outlined,
                            label: meal.category,
                          ),
                          _InfoChip(
                            icon: Icons.public_outlined,
                            label: meal.area,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ValueListenableBuilder<Box<dynamic>>(
                        valueListenable: _favoriteService.listenable,
                        builder: (context, box, _) {
                          final isFavorite = box.containsKey(meal.id);

                          return SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () =>
                                  _toggleFavorite(meal, isFavorite),
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              label: Text(
                                isFavorite
                                    ? 'Hapus dari Favorit'
                                    : 'Tambah ke Favorit',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 26),
                      _SectionTitle(
                        icon: Icons.list_alt_outlined,
                        title: 'Bahan',
                      ),
                      const SizedBox(height: 8),
                      ...meal.ingredients.asMap().entries.map((entry) {
                        final number = entry.key + 1;
                        final ingredient = entry.value;

                        return _IngredientRow(
                          number: number,
                          ingredient: ingredient,
                        );
                      }),
                      const SizedBox(height: 24),
                      _SectionTitle(
                        icon: Icons.soup_kitchen_outlined,
                        title: 'Instruksi Memasak',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        meal.instructions,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: const Color(0xFF006B61)),
      label: Text(label),
      backgroundColor: const Color(0xFFE4F4F1),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF008577)),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.number, required this.ingredient});

  final int number;
  final IngredientItem ingredient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF008577),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.ingredient,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  ingredient.measure,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.black45),
            const SizedBox(height: 12),
            const Text(
              'Detail resep belum berhasil dimuat.',
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

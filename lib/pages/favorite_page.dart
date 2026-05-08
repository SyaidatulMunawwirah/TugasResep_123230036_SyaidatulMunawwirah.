import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/meal_summary.dart';
import '../services/favorite_service.dart';
import 'detail_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  static final _favoriteService = FavoriteService();

  void _openDetail(BuildContext context, MealSummary meal) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DetailPage(mealId: meal.id)));
  }

  Future<void> _removeFavorite(BuildContext context, MealSummary meal) async {
    await _favoriteService.remove(meal.id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${meal.name} dihapus dari favorit.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: _favoriteService.listenable,
      builder: (context, box, _) {
        final favorites = _favoriteService.getAllFavorites();

        if (favorites.isEmpty) {
          return const _FavoriteEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final meal = favorites[index];

            return Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    meal.thumbnail,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 72,
                        height: 72,
                        color: const Color(0xFFE5ECE9),
                        child: const Icon(Icons.restaurant_menu),
                      );
                    },
                  ),
                ),
                title: Text(
                  meal.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Ketuk untuk melihat detail'),
                trailing: IconButton(
                  tooltip: 'Hapus favorit',
                  onPressed: () => _removeFavorite(context, meal),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                onTap: () => _openDetail(context, meal),
              ),
            );
          },
        );
      },
    );
  }
}

class _FavoriteEmptyState extends StatelessWidget {
  const _FavoriteEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.black38),
            const SizedBox(height: 12),
            Text(
              'Belum ada resep favorit.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Simpan resep dari halaman detail agar muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

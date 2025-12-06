import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/utils/url_utils.dart';
import '../../data/models/cat_breed.dart';
import '../../data/models/cat_image.dart';

class CatDetailsPage extends StatelessWidget {
  const CatDetailsPage({super.key, required this.cat});

  final CatImage cat;

  @override
  Widget build(BuildContext context) {
    final breed = cat.breed;
    return Scaffold(
      appBar: AppBar(title: Text(breed?.name ?? 'Котик')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: CachedNetworkImage(
                  imageUrl: webSafeImageUrl(cat.url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (breed != null)
              _BreedDetails(breed: breed)
            else
              const Text('Информация о породе недоступна'),
          ],
        ),
      ),
    );
  }
}

class _BreedDetails extends StatelessWidget {
  const _BreedDetails({required this.breed});

  final CatBreed breed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(breed.name, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(breed.description, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        _StatRow(title: 'Происхождение', value: breed.origin),
        _StatRow(title: 'Темперамент', value: breed.temperament),
        _StatRow(
          title: 'Продолжительность жизни',
          value: '${breed.lifeSpan} лет',
        ),
        _StatRow(title: 'Интеллект', value: breed.intelligence.toString()),
        _StatRow(title: 'Адаптивность', value: breed.adaptability.toString()),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white70)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

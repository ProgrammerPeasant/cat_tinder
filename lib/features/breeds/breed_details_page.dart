import 'package:flutter/material.dart';

import '../../data/models/cat_breed.dart';

class BreedDetailsPage extends StatelessWidget {
  const BreedDetailsPage({super.key, required this.breed});

  final CatBreed breed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(breed.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoChip(label: breed.origin, icon: Icons.public),
            const SizedBox(height: 12),
            Text(
              breed.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _StatCard(title: 'Темперамент', value: breed.temperament),
            _StatCard(title: 'Продолжительность жизни', value: breed.lifeSpan),
            _StatCard(title: 'Интеллект', value: breed.intelligence.toString()),
            _StatCard(
              title: 'Адаптивность',
              value: breed.adaptability.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: Colors.white),
      label: Text(label),
      backgroundColor: Colors.white.withValues(alpha: 0.1),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
  color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

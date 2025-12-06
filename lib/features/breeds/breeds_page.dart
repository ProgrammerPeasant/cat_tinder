import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/load_state.dart';
import '../../core/ui/error_dialog.dart';
import '../../data/models/cat_breed.dart';
import 'breed_details_page.dart';
import 'breeds_controller.dart';

class BreedsPage extends StatefulWidget {
  const BreedsPage({super.key});

  @override
  State<BreedsPage> createState() => _BreedsPageState();
}

class _BreedsPageState extends State<BreedsPage> {
  String? _visibleError;

  @override
  Widget build(BuildContext context) {
    return Consumer<BreedsController>(
      builder: (context, controller, _) {
        final errorMessage = controller.lastError?.message;
        if (controller.state == LoadState.error &&
            errorMessage != null &&
            errorMessage != _visibleError) {
          _visibleError = errorMessage;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await showErrorDialog(
              context,
              title: 'Ошибка',
              message: errorMessage,
              onRetry: () => controller.loadBreeds(force: true),
            );
            if (mounted) {
              setState(() => _visibleError = null);
            }
          });
        }
        if (controller.state == LoadState.loading &&
            controller.breeds.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => controller.loadBreeds(force: true),
          child: controller.breeds.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 200),
                    Center(child: Text('Не удалось загрузить породы :(')),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  itemBuilder: (context, index) {
                    final breed = controller.breeds[index];
                    return _BreedTile(breed: breed);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: controller.breeds.length,
                ),
        );
      },
    );
  }
}

class _BreedTile extends StatelessWidget {
  const _BreedTile({required this.breed});

  final CatBreed breed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        breed.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${breed.origin} • ${breed.temperament}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => BreedDetailsPage(breed: breed))),
    );
  }
}

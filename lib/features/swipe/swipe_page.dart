import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/load_state.dart';
import '../../core/ui/error_dialog.dart';
import '../../data/models/cat_image.dart';
import '../../core/utils/url_utils.dart';
import 'cat_details_page.dart';
import 'swipe_controller.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  String? _visibleError;

  @override
  Widget build(BuildContext context) {
    return Consumer<SwipeController>(
      builder: (context, controller, _) {
        final errorMessage = controller.lastError?.message;
        if (controller.state == LoadState.error &&
            errorMessage != null &&
            errorMessage != _visibleError) {
          _visibleError = errorMessage;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await showErrorDialog(
              context,
              title: 'Упс, ошибка',
              message: errorMessage,
              onRetry: controller.refresh,
            );
            if (mounted) {
              setState(() => _visibleError = null);
            }
          });
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Expanded(child: _buildCardSection(context, controller)),
              const SizedBox(height: 20),
              _buildActions(controller),
              const SizedBox(height: 16),
              _buildCounter(controller.likes),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardSection(BuildContext context, SwipeController controller) {
    if (controller.state == LoadState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.currentCat == null) {
      return const Center(child: Text('Нет котиков :('));
    }
    final cat = controller.currentCat!;
    return Dismissible(
      key: ValueKey(cat.id + controller.likes.toString()),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        HapticFeedback.selectionClick();
        if (direction == DismissDirection.startToEnd) {
          controller.like();
        } else {
          controller.dislike();
        }
      },
      child: GestureDetector(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => CatDetailsPage(cat: cat))),
        child: _CatCard(cat: cat),
      ),
    );
  }

  Widget _buildCounter(int likes) {
    return Column(
      children: [
        const Text('Лайков котикам', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          '$likes',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActions(SwipeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RoundButton(
          icon: Icons.close,
          color: Colors.white,
          background: Colors.white.withValues(alpha: 0.1),
          onTap: controller.dislike,
        ),
        _RoundButton(
          icon: Icons.favorite,
          color: Colors.white,
          background: const Color(0xFFFF5678),
          onTap: controller.like,
        ),
      ],
    );
  }
}

class _CatCard extends StatelessWidget {
  const _CatCard({required this.cat});

  final CatImage cat;

  @override
  Widget build(BuildContext context) {
    final breed = cat.breed;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1A2E), Color(0xFF2B1C2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: webSafeImageUrl(cat.url),
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.image_not_supported)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                begin: Alignment.center,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  breed?.name ?? 'Неизвестная порода',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  breed?.origin ?? 'Неизвестно',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: background.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 36),
      ),
    );
  }
}

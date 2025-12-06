import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/dio_client.dart';
import 'core/ui/app_theme.dart';
import 'data/repositories/cat_repository.dart';
import 'data/services/cat_api_client.dart';
import 'features/breeds/breeds_controller.dart';
import 'features/breeds/breeds_page.dart';
import 'features/swipe/swipe_controller.dart';
import 'features/swipe/swipe_page.dart';

class CatTinderApp extends StatelessWidget {
  const CatTinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => CatRepository(CatApiClient(createDioClient()))),
        ChangeNotifierProvider(
          create: (context) =>
              SwipeController(context.read<CatRepository>())..init(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              BreedsController(context.read<CatRepository>())..loadBreeds(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cat Tinder',
        theme: buildCatTinderTheme(),
        home: const _HomeShell(),
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _currentIndex == 0
                ? const SwipePage(key: ValueKey('swipe'))
                : const BreedsPage(key: ValueKey('breeds')),
          ),
          _GlassBottomNav(
            currentIndex: _currentIndex,
            onChanged: (value) => setState(() => _currentIndex = value),
          ),
        ],
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({required this.currentIndex, required this.onChanged});

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
  color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(40),
  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.local_fire_department,
            label: 'Свайпы',
            isActive: currentIndex == 0,
            onTap: () => onChanged(0),
          ),
          _NavItem(
            icon: Icons.pets,
            label: 'Породы',
            isActive: currentIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Colors.white70;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

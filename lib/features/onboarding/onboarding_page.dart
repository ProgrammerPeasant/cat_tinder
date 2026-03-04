import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/services/onboarding_service.dart';
import 'onboarding_controller.dart';

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({Key? key}) : super(key: key);

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingController>(
      builder: (context, onboardingController, _) {
        return Scaffold(
          body: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  onboardingController.goToPage(index);
                },
                itemCount: onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = onboardingPages[index];
                  return _OnboardingSlide(
                    page: page,
                    isLast: index == onboardingPages.length - 1,
                    onNext: () {
                      if (index == onboardingPages.length - 1) {
                        _finishOnboarding(context, onboardingController);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    onSkip: () {
                      _finishOnboarding(context, onboardingController);
                    },
                  );
                },
              ),
              Positioned(
                bottom: 120,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: onboardingPages.length,
                    effect: CustomizableEffect(
                      activeDotDecoration: DotDecoration(
                        width: 12,
                        height: 12,
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      dotDecoration: DotDecoration(
                        width: 8,
                        height: 8,
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      spacing: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _finishOnboarding(
    BuildContext context,
    OnboardingController controller,
  ) async {
    await controller.completeOnboarding();
  }
}

class _OnboardingSlide extends StatefulWidget {
  const _OnboardingSlide({
    required this.page,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  final OnboardingPage page;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<_OnboardingSlide> createState() => _OnboardingSlideStat();
}

class _OnboardingSlideStat extends State<_OnboardingSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(_OnboardingSlide oldWidget) {
    super.didUpdateWidget(widget);
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0D0C12),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Skip button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!widget.isLast)
                  GestureDetector(
                    onTap: widget.onSkip,
                    child: Text(
                      'Пропустить',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ),
              ],
            ),
            // Content
            ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  Text(
                    widget.page.emoji,
                    style: const TextStyle(fontSize: 120),
                  ),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            widget.page.title,
                            style:
                                Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.page.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white70,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.isLast ? 'Начать' : 'Далее',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

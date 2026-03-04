import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingService {
  Future<bool> hasCompletedOnboarding();
  Future<void> completeOnboarding();
}

class OnboardingServiceImpl implements OnboardingService {
  const OnboardingServiceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;
  static const String _onboardingKey = 'onboarding_completed';

  @override
  Future<bool> hasCompletedOnboarding() async {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingKey, true);
  }
}

class OnboardingPage {
  OnboardingPage({
    required this.title,
    required this.description,
    required this.emoji,
  });

  final String title;
  final String description;
  final String emoji;
}

final List<OnboardingPage> onboardingPages = [
  OnboardingPage(
    title: 'Добро пожаловать в Cat Tinder',
    description: 'Найди идеального котика и узнай о его породе',
    emoji: '🐱',
  ),
  OnboardingPage(
    title: 'Свайпай с удовольствием',
    description: 'Лайкни котика направо, дизлайкни налево. Или используй кнопки ниже',
    emoji: '👆',
  ),
  OnboardingPage(
    title: 'Узнай подробности',
    description: 'Тапни по карточке и узнай все о характере и происхождении котика',
    emoji: '📖',
  ),
  OnboardingPage(
    title: 'Изучай породы',
    description: 'Посмотри полный список пород и выбери свега любимца',
    emoji: '🗂️',
  ),
];

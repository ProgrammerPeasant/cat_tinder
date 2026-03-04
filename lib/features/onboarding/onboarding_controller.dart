import 'package:flutter/material.dart';
import '../../core/services/onboarding_service.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingController(this._onboardingService) {
    _init();
  }

  final OnboardingService _onboardingService;
  int _currentPage = 0;
  bool _hasCompletedOnboarding = false;
  bool _isInitialized = false;

  int get currentPage => _currentPage;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    try {
      _hasCompletedOnboarding =
          await _onboardingService.hasCompletedOnboarding();
    } catch (e) {
      _hasCompletedOnboarding = false;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    await _onboardingService.completeOnboarding();
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  void goToPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    _currentPage++;
    notifyListeners();
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }
}


abstract class AnalyticsService {
  Future<void> logEvent(String eventName, Map<String, Object>? parameters);
  Future<void> setUserId(String? userId);
  Future<void> clearUserId();
}

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({required dynamic analytics})
      : _analytics = analytics;

  final dynamic _analytics;

  @override
  Future<void> logEvent(
    String eventName,
    Map<String, Object>? parameters,
  ) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      // Firebase Analytics setUserId doesn't take arguments, it's set via properties
      if (userId != null) {
        await _analytics.setUserId(userId);
      }
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  @override
  Future<void> clearUserId() async {
    try {
      await _analytics.setUserId(null);
    } catch (e) {
      print('Analytics error: $e');
    }
  }
}

class LocalAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(
    String eventName,
    Map<String, Object>? parameters,
  ) async {
    final timestamp = DateTime.now().toIso8601String();
    print('[Analytics] $timestamp - Event: $eventName, Parameters: $parameters');
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (userId != null) {
      print('[Analytics] User ID set: $userId');
    }
  }

  @override
  Future<void> clearUserId() async {
    print('[Analytics] User ID cleared');
  }
}

// Event names
class AnalyticsEvents {
  static const String userRegistered = 'user_registered';
  static const String userLoggedIn = 'user_logged_in';
  static const String userLoggedOut = 'user_logged_out';
  static const String registrationFailed = 'registration_failed';
  static const String loginFailed = 'login_failed';
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String catLiked = 'cat_liked';
  static const String catDisliked = 'cat_disliked';
  static const String breedViewed = 'breed_viewed';
}

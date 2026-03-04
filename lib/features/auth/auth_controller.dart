import 'package:flutter/material.dart';
import '../../core/load_state.dart';
import '../../core/models/auth_exception.dart';
import '../../core/models/user.dart';
import '../../core/services/local_auth_service.dart';
import '../../core/services/analytics_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(
    this._authService, {
    required AnalyticsService analyticsService,
  }) : _analyticsService = analyticsService;

  final LocalAuthService _authService;
  final AnalyticsService _analyticsService;

  User? _currentUser;
  LoadState _state = LoadState.initial;
  AuthException? _error;

  User? get currentUser => _currentUser;
  LoadState get state => _state;
  AuthException? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      await _analyticsService.logEvent(
        AnalyticsEvents.userRegistered,
        {'email': email, 'displayName': displayName},
      );
      
      await _analyticsService.setUserId(_currentUser!.id);
      
      _state = LoadState.success;
    } on AuthException catch (e) {
      _error = e;
      _state = LoadState.error;
      
      await _analyticsService.logEvent(
        AnalyticsEvents.registrationFailed,
        {'email': email, 'reason': e.message},
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(
        email: email,
        password: password,
      );
      
      _state = LoadState.success;
      notifyListeners();
      
      await _analyticsService.logEvent(
        AnalyticsEvents.userLoggedIn,
        {'email': email},
      );
      
      await _analyticsService.setUserId(_currentUser!.id);
    } on AuthException catch (e) {
      _error = e;
      _state = LoadState.error;
      
      await _analyticsService.logEvent(
        AnalyticsEvents.loginFailed,
        {'email': email, 'reason': e.message},
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      
      await _analyticsService.logEvent(
        AnalyticsEvents.userLoggedOut,
        null,
      );
      
      await _analyticsService.clearUserId();
      
      _currentUser = null;
      _state = LoadState.initial;
      _error = null;
    } catch (e) {
      _error = AuthStorageException('Logout failed');
    } finally {
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isUserLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
        
        if (_currentUser != null) {
          await _analyticsService.setUserId(_currentUser!.id);
        }
        
        _state = LoadState.success;
      } else {
        _currentUser = null;
        _state = LoadState.initial;
      }
    } catch (e) {
      _currentUser = null;
      _state = LoadState.initial;
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

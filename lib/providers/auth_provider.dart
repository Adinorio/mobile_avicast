import 'package:flutter/foundation.dart';
import 'package:mobile_avicast/models/user.dart';
import 'package:mobile_avicast/services/auth_service.dart';
import 'package:mobile_avicast/services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  final AuthService _authService = AuthService();
  final LocalStorageService _localStorage = LocalStorageService();

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    try {
      final storedUser = await _localStorage.getStoredUser();
      if (storedUser != null) {
        _currentUser = storedUser;
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading stored user: $e');
    }
  }

  Future<bool> login(String employeeId, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Try online login first
      final user = await _authService.login(employeeId, password);
      if (user != null) {
        await _handleSuccessfulLogin(user);
        return true;
      } else {
        // Try offline login
        final offlineUser = await _authService.offlineLogin(employeeId, password);
        if (offlineUser != null) {
          await _handleSuccessfulLogin(offlineUser);
          return true;
        } else {
          _setError('Invalid credentials');
          return false;
        }
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleSuccessfulLogin(User user) async {
    _currentUser = user;
    _isAuthenticated = true;
    
    // Store user locally for offline access
    await _localStorage.storeUser(user);
    
    // Store authentication token if available
    if (user.id != null) {
      await _localStorage.storeAuthToken(user.id.toString());
    }
    
    notifyListeners();
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // Clear local storage
      await _localStorage.clearUserData();
      
      // Clear current state
      _currentUser = null;
      _isAuthenticated = false;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> validateOfflineAccess(String employeeId) async {
    try {
      final storedUser = await _localStorage.getStoredUser();
      if (storedUser != null && storedUser.employeeId == employeeId) {
        _currentUser = storedUser;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error validating offline access: $e');
      return false;
    }
  }

  Future<void> refreshUserData() async {
    if (_currentUser == null) return;
    
    try {
      final updatedUser = await _authService.getUserProfile(_currentUser!.employeeId);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        await _localStorage.storeUser(updatedUser);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
} 
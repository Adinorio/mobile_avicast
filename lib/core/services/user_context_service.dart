import 'package:shared_preferences/shared_preferences.dart';

class UserContextService {
  static const String _currentUserIdKey = 'current_user_id';
  static const String _currentUserNameKey = 'current_user_name';

  static final UserContextService _instance = UserContextService._internal();
  factory UserContextService() => _instance;
  UserContextService._internal();

  static UserContextService get instance => _instance;

  // Get current user ID
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserIdKey);
  }

  // Set current user ID
  Future<void> setCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserIdKey, userId);
  }

  // Get current user name
  Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserNameKey);
  }

  // Set current user name
  Future<void> setCurrentUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserNameKey, userName);
  }

  // Clear current user data
  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
    await prefs.remove(_currentUserNameKey);
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final userId = await getCurrentUserId();
    return userId != null && userId.isNotEmpty;
  }
} 
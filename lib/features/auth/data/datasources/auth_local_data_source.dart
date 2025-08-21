import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCachedUser();
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> clearCachedToken();
  Future<void> cacheRefreshToken(String refreshToken);
  Future<String?> getCachedRefreshToken();
  Future<void> clearCachedRefreshToken();
} 
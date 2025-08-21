import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'cached_token';
  static const String _refreshTokenKey = 'cached_refresh_token';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = user.toJson();
      await sharedPreferences.setString(_userKey, jsonEncode(userJson));
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userString = sharedPreferences.getString(_userKey);
      if (userString != null) {
        final userJson = jsonDecode(userString) as Map<String, dynamic>;
        return UserModel.fromJson(userJson);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await sharedPreferences.remove(_userKey);
    } catch (e) {
      throw CacheException('Failed to clear cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      await sharedPreferences.setString(_tokenKey, token);
    } catch (e) {
      throw CacheException('Failed to cache token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getCachedToken() async {
    try {
      return sharedPreferences.getString(_tokenKey);
    } catch (e) {
      throw CacheException('Failed to get cached token: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCachedToken() async {
    try {
      await sharedPreferences.remove(_tokenKey);
    } catch (e) {
      throw CacheException('Failed to clear cached token: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheRefreshToken(String refreshToken) async {
    try {
      await sharedPreferences.setString(_refreshTokenKey, refreshToken);
    } catch (e) {
      throw CacheException('Failed to cache refresh token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getCachedRefreshToken() async {
    try {
      return sharedPreferences.getString(_refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to get cached refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCachedRefreshToken() async {
    try {
      await sharedPreferences.remove(_refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to clear cached refresh token: ${e.toString()}');
    }
  }
} 
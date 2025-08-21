import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String userId, String password);
  Future<UserModel> signUp(String userId, String password, String name);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<bool> isSignedIn();
  Future<void> forgotPassword(String userId);
  Future<void> resetPassword(String token, String newPassword);
  Future<UserModel> updateProfile(UserModel user);
  Future<void> changePassword(String currentPassword, String newPassword);
} 
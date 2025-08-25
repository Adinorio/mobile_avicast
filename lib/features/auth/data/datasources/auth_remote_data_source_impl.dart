import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> signIn(String userId, String password) async {
    // TODO: Implement actual API call
    // For now, simulate a delay and return mock data
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate API validation
    if (userId.isEmpty || password.isEmpty) {
      throw const AuthException('User ID and password are required');
    }
    
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters');
    }
    
    // Predefined users with unique passwords for development
    if (userId == '24-0925-001' && password == 'password123') {
      return UserModel(
        id: '24-0925-001',
        email: 'researcher@avicast.org',
        name: 'Field Researcher',
        profilePicture: null,
        roles: ['researcher', 'user'],
        createdAt: DateTime.now(),
        lastLoginAt: null,
        isActive: true,
      );
    }
    
    if (userId == '24-0925-002' && password == 'password456') {
      return UserModel(
        id: '24-0925-002',
        email: 'observer@avicast.org',
        name: 'Bird Observer',
        profilePicture: null,
        roles: ['observer', 'user'],
        createdAt: DateTime.now(),
        lastLoginAt: null,
        isActive: true,
      );
    }
    
    if (userId == '24-0925-003' && password == 'password789') {
      return UserModel(
        id: '24-0925-003',
        email: 'analyst@avicast.org',
        name: 'Data Analyst',
        profilePicture: null,
        roles: ['analyst', 'user'],
        createdAt: DateTime.now(),
        lastLoginAt: null,
        isActive: true,
      );
    }
    
    // If credentials don't match any predefined user, reject login
    throw const AuthException('Invalid User ID or password. Please check your credentials.');
  }

  @override
  Future<UserModel> signUp(String userId, String password, String name) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (userId.isEmpty || password.isEmpty || name.isEmpty) {
      throw const ValidationException('All fields are required');
    }
    
    if (password.length < 6) {
      throw const ValidationException('Password must be at least 6 characters');
    }
    
    // Prevent creating users with predefined IDs
    if (userId == '24-0925-001' || userId == '24-0925-002' || userId == '24-0925-003') {
      throw const ValidationException('This User ID is reserved and cannot be used for registration');
    }
    
    return UserModel(
      id: userId,
      email: 'user@avicast.org',
      name: name,
      profilePicture: null,
      roles: ['user'],
      createdAt: DateTime.now(),
      lastLoginAt: null,
      isActive: true,
    );
  }

  @override
  Future<void> signOut() async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // For development: Return a default user so you can access the app immediately
    return UserModel(
      id: 'default_user_001',
      email: 'admin@avicast.com',
      name: 'Admin User',
      profilePicture: null,
      roles: ['admin', 'user'],
      createdAt: DateTime.now(),
      lastLoginAt: null,
      isActive: true,
    );
  }

  @override
  Future<bool> isSignedIn() async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }

  @override
  Future<void> forgotPassword(String userId) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (userId.isEmpty) {
      throw const ValidationException('User ID is required');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (token.isEmpty || newPassword.isEmpty) {
      throw const ValidationException('Token and new password are required');
    }
    
    if (newPassword.length < 6) {
      throw const ValidationException('Password must be at least 6 characters');
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (user.name.isEmpty) {
      throw const ValidationException('Name is required');
    }
    
    return user;
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      throw const ValidationException('Both passwords are required');
    }
    
    if (newPassword.length < 6) {
      throw const ValidationException('New password must be at least 6 characters');
    }
    
    if (currentPassword == newPassword) {
      throw const ValidationException('New password must be different from current password');
    }
  }
} 
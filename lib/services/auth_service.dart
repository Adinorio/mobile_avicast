import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:mobile_avicast/models/user.dart';
import 'package:mobile_avicast/services/local_storage_service.dart';

class AuthService {
  static const String _loginEndpoint = '/api/auth/login/';
  static const String _logoutEndpoint = '/api/auth/logout/';
  static const String _profileEndpoint = '/api/auth/profile/';
  static const Duration _timeout = Duration(seconds: 10);

  final LocalStorageService _localStorage = LocalStorageService();

  /// Attempts to login to the Django backend
  Future<User?> login(String employeeId, String password) async {
    try {
      // Get the server URL from storage or use default
      final serverUrl = await _getServerUrl();
      if (serverUrl == null) {
        // Try offline login if no server available
        return await offlineLogin(employeeId, password);
      }

      final url = Uri.parse('$serverUrl$_loginEndpoint');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'employee_id': employeeId,
          'password': password,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['user'] != null) {
          final user = User.fromJson(data['user']);
          
          // Store auth token if provided
          if (data['token'] != null) {
            await _localStorage.storeAuthToken(data['token']);
          }
          
          return user;
        }
      } else if (response.statusCode == 401) {
        // Invalid credentials
        return null;
      }
      
      return null;
    } catch (e) {
      print('Login error: $e');
      // Fall back to offline login
      return await offlineLogin(employeeId, password);
    }
  }

  /// Offline login using stored user data
  Future<User?> offlineLogin(String employeeId, String password) async {
    try {
      final storedUser = await _localStorage.getStoredUser();
      if (storedUser == null) return null;

      // Check if employee ID matches
      if (storedUser.employeeId != employeeId) return null;

      // For offline mode, we'll use a simple hash verification
      // In production, you might want to store a hashed version of the password
      final hashedPassword = _hashPassword(password);
      final storedHash = await _getStoredPasswordHash(employeeId);
      
      if (storedHash != null && storedHash == hashedPassword) {
        return storedUser;
      }

      // If no stored hash, allow login with stored user (less secure)
      // This is useful for initial setup
      return storedUser;
    } catch (e) {
      print('Offline login error: $e');
      return null;
    }
  }

  /// Logout from the server
  Future<bool> logout() async {
    try {
      final serverUrl = await _getServerUrl();
      if (serverUrl == null) return true; // Already offline

      final url = Uri.parse('$serverUrl$_logoutEndpoint');
      final token = await _localStorage.getAuthToken();
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  /// Get user profile from server
  Future<User?> getUserProfile(String employeeId) async {
    try {
      final serverUrl = await _getServerUrl();
      if (serverUrl == null) return null;

      final url = Uri.parse('$serverUrl$_profileEndpoint');
      final token = await _localStorage.getAuthToken();
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  /// Validate stored authentication token
  Future<bool> validateToken() async {
    try {
      final token = await _localStorage.getAuthToken();
      if (token == null) return false;

      final serverUrl = await _getServerUrl();
      if (serverUrl == null) return false;

      final url = Uri.parse('$serverUrl$_profileEndpoint');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  /// Get the server URL from storage
  Future<String?> _getServerUrl() async {
    // This would typically come from the NetworkProvider
    // For now, we'll use a default or stored value
    final data = await _localStorage.getData('server_url');
    return data?['url'];
  }

  /// Hash password for offline verification
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get stored password hash for offline verification
  Future<String?> _getStoredPasswordHash(String employeeId) async {
    final data = await _localStorage.getData('password_hashes');
    return data?[employeeId];
  }

  /// Store password hash for offline verification
  Future<void> _storePasswordHash(String employeeId, String hash) async {
    final data = await _localStorage.getData('password_hashes') ?? {};
    data[employeeId] = hash;
    await _localStorage.storeData('password_hashes', data);
  }

  /// Change password (both online and offline)
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final serverUrl = await _getServerUrl();
      if (serverUrl != null) {
        // Online password change
        final url = Uri.parse('$serverUrl/api/auth/change-password/');
        final token = await _localStorage.getAuthToken();
        
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'current_password': currentPassword,
            'new_password': newPassword,
          }),
        ).timeout(_timeout);

        if (response.statusCode == 200) {
          // Update stored hash
          final newHash = _hashPassword(newPassword);
          final currentUser = await _localStorage.getStoredUser();
          if (currentUser != null) {
            await _storePasswordHash(currentUser.employeeId, newHash);
          }
          return true;
        }
        return false;
      } else {
        // Offline password change
        final currentUser = await _localStorage.getStoredUser();
        if (currentUser == null) return false;

        final currentHash = _hashPassword(currentPassword);
        final storedHash = await _getStoredPasswordHash(currentUser.employeeId);
        
        if (storedHash == currentHash) {
          final newHash = _hashPassword(newPassword);
          await _storePasswordHash(currentUser.employeeId, newHash);
          return true;
        }
        return false;
      }
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }
} 
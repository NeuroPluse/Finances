import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Supabase _supabase;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthService(this._supabase);

  Future<dynamic> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print(
          'Attempting to register with email: $email, password: $password, name: $name');
      final response = await _supabase.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      print('Register response: $response');
      print('Registered user: ${response.user}');
      if (response.user == null) {
        print('Supabase returned null user after registration');
      }
      return response.user;
    } catch (e) {
      print('Error in register: $e');
      rethrow;
    }
  }

  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting to login with email: $email, password: $password');
      final response = await _supabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('Login response: $response');
      print('User after login: ${response.user}');
      return response.user;
    } catch (e) {
      print('Error in login: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    print('Attempting to logout');
    await _supabase.client.auth.signOut();
    final userAfterLogout = _supabase.client.auth.currentUser;
    print('User after logout: $userAfterLogout');
  }

  dynamic getCurrentUser() {
    final user = _supabase.client.auth.currentUser;
    print('Getting current user: $user');
    return user;
  }

  Future<void> saveSession(
      String email, String password, bool rememberMe) async {
    if (rememberMe) {
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'password', value: password);
      await _secureStorage.write(key: 'rememberMe', value: 'true');
      print('Session saved for: $email');
    } else {
      await clearSession();
    }
  }

  Future<Map<String, String?>> getSavedSession() async {
    final rememberMe = await _secureStorage.read(key: 'rememberMe');
    if (rememberMe == 'true') {
      final email = await _secureStorage.read(key: 'email');
      final password = await _secureStorage.read(key: 'password');
      print('Found saved session for: $email');
      return {'email': email, 'password': password};
    }
    return {'email': null, 'password': null};
  }

  Future<void> clearSession() async {
    try {
      print('Clearing saved session');
      await _secureStorage.delete(key: 'email');
      await _secureStorage.delete(key: 'password');
      await _secureStorage.write(key: 'rememberMe', value: 'false');
      print('Session cleared successfully');
    } catch (e) {
      print('Error clearing session: $e');

      await _secureStorage.deleteAll();
      print('Used deleteAll as fallback');
    }
  }
}

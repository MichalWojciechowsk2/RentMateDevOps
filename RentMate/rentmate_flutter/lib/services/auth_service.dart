import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'https://localhost:7281/api';
  static const String tokenKey = 'auth_token';
  final _secureStorage = const FlutterSecureStorage();

  Future<void> _persistUserData(String token, Map<String, dynamic> userData) async {
    await _secureStorage.write(key: tokenKey, value: token);
    await _secureStorage.write(key: 'user_data', value: jsonEncode(userData));
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: tokenKey);
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        await logout(); // Token might be invalid, log out
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<User> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    required String role,
    String? aboutMe,
    String? photoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'role': role,
          if (aboutMe != null) 'aboutMe': aboutMe,
          if (photoUrl != null) 'photoUrl': photoUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _persistUserData(data['token'], data['user']);
        return User.fromJson(data['user']);
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _persistUserData(data['token'], data['user']);
        return User.fromJson(data['user']);
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: tokenKey);
    await _secureStorage.delete(key: 'user_data');
  }
} 
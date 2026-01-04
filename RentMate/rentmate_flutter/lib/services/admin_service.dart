import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/admin_user.dart';
import '../models/admin_review.dart';

class AdminService {
  static const String baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  Future<List<AdminUser>> getAllUsers() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AdminUser.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Brak uprawnień administratora');
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting users: $e');
    }
  }

  Future<bool> banUser(int userId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/Admin/users/$userId/ban'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Brak uprawnień administratora');
      } else {
        throw Exception('Failed to ban user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error banning user: $e');
    }
  }

  Future<bool> unbanUser(int userId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/Admin/users/$userId/unban'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Brak uprawnień administratora');
      } else {
        throw Exception('Failed to unban user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error unbanning user: $e');
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.delete(
        Uri.parse('$baseUrl/Admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Brak uprawnień administratora');
      } else {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  Future<List<AdminReview>> getAllReviews() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Admin/reviews'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AdminReview.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Brak uprawnień administratora');
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting reviews: $e');
    }
  }

  Future<bool> deleteReview(int reviewId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.delete(
        Uri.parse('$baseUrl/Admin/reviews/$reviewId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Brak uprawnień administratora');
      } else {
        throw Exception('Failed to delete review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }
}


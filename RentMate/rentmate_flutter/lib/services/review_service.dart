import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import 'auth_service.dart';

class ReviewService {
  final String _baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  Future<Review> createReview(CreateReviewDto dto) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Review'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
        body: json.encode(dto.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Review.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create review: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  Future<List<Review>> getReviewsForUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Review/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  Future<List<Review>> getReviewsForProperty(int propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Review/property/$propertyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/Review/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete review: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}

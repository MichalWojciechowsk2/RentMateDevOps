import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/report.dart';

class ReportService {
  static const String baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  Future<Report> createReport(int reportedUserId, String reason) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/Report'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reportedUserId': reportedUserId,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Report.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message']?.toString() ?? 'Błąd podczas zgłaszania użytkownika');
      }
    } catch (e) {
      throw Exception('Error creating report: $e');
    }
  }

  Future<List<Report>> getAllReports() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Report/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Report.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Brak uprawnień administratora');
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting reports: $e');
    }
  }

  Future<List<Report>> getUnresolvedReports() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Report/unresolved'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Report.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Brak uprawnień administratora');
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting reports: $e');
    }
  }

  Future<bool> resolveReport(int reportId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/Report/$reportId/resolve'),
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
        throw Exception('Failed to resolve report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error resolving report: $e');
    }
  }
}


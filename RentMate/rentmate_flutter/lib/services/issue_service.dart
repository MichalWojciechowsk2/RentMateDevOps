import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class IssueService {
  static const String baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  // Utwórz problem
  Future<Map<String, dynamic>> createIssue({
    required int propertyId,
    required String title,
    required String description,
    required String urgency, // 'Low', 'Medium', 'High', 'Critical'
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      // Mapuj string na enum value
      int urgencyValue;
      switch (urgency) {
        case 'Low':
          urgencyValue = 0;
          break;
        case 'Medium':
          urgencyValue = 1;
          break;
        case 'High':
          urgencyValue = 2;
          break;
        case 'Critical':
          urgencyValue = 3;
          break;
        default:
          urgencyValue = 1; // Medium jako domyślny
      }

      final response = await http.post(
        Uri.parse('$baseUrl/Issue'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'propertyId': propertyId,
          'title': title,
          'description': description,
          'urgency': urgencyValue,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'id': data['id'] is int ? data['id'] : int.tryParse(data['id']?.toString() ?? '') ?? 0,
          'propertyId': data['propertyId'] is int ? data['propertyId'] : int.tryParse(data['propertyId']?.toString() ?? '') ?? 0,
          'tenantId': data['tenantId'] is int ? data['tenantId'] : int.tryParse(data['tenantId']?.toString() ?? '') ?? 0,
          'title': data['title']?.toString() ?? '',
          'description': data['description']?.toString() ?? '',
          'status': data['status']?.toString() ?? 'New',
          'urgency': data['urgency']?.toString() ?? 'Medium',
          'createdAt': data['createdAt'] != null ? DateTime.parse(data['createdAt'].toString()) : DateTime.now(),
          'resolvedAt': data['resolvedAt'] != null ? DateTime.parse(data['resolvedAt'].toString()) : null,
        };
      } else {
        throw Exception('Failed to create issue: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating issue: $e');
    }
  }

  // Pobierz problemy dla mieszkania (dla właściciela)
  Future<List<Map<String, dynamic>>> getIssuesByPropertyId(int propertyId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Issue/property/$propertyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((issue) {
          // Konwertuj urgency z enum (liczba) na string
          String urgencyStr = 'Medium';
          if (issue['urgency'] != null) {
            final urgencyValue = issue['urgency'];
            if (urgencyValue is int) {
              switch (urgencyValue) {
                case 0:
                  urgencyStr = 'Low';
                  break;
                case 1:
                  urgencyStr = 'Medium';
                  break;
                case 2:
                  urgencyStr = 'High';
                  break;
                case 3:
                  urgencyStr = 'Critical';
                  break;
                default:
                  urgencyStr = 'Medium';
              }
            } else {
              urgencyStr = urgencyValue.toString();
            }
          }
          
          // Konwertuj status z enum (liczba) na string
          String statusStr = 'New';
          if (issue['status'] != null) {
            final statusValue = issue['status'];
            if (statusValue is int) {
              switch (statusValue) {
                case 0:
                  statusStr = 'New';
                  break;
                case 1:
                  statusStr = 'InProgress';
                  break;
                case 2:
                  statusStr = 'Resolved';
                  break;
                case 3:
                  statusStr = 'Closed';
                  break;
                default:
                  statusStr = 'New';
              }
            } else {
              statusStr = statusValue.toString();
            }
          }
          
          return {
            'id': issue['id'] is int ? issue['id'] : int.tryParse(issue['id']?.toString() ?? '') ?? 0,
            'propertyId': issue['propertyId'] is int ? issue['propertyId'] : int.tryParse(issue['propertyId']?.toString() ?? '') ?? 0,
            'tenantId': issue['tenantId'] is int ? issue['tenantId'] : int.tryParse(issue['tenantId']?.toString() ?? '') ?? 0,
            'title': issue['title']?.toString() ?? '',
            'description': issue['description']?.toString() ?? '',
            'status': statusStr,
            'urgency': urgencyStr,
            'createdAt': issue['createdAt'] != null ? DateTime.parse(issue['createdAt'].toString()) : DateTime.now(),
            'resolvedAt': issue['resolvedAt'] != null ? DateTime.parse(issue['resolvedAt'].toString()) : null,
          };
        }).toList();
      } else {
        throw Exception('Failed to load issues: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting issues: $e');
    }
  }

  // Pobierz problemy najemcy
  Future<List<Map<String, dynamic>>> getIssuesByTenantId() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Issue/tenant'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((issue) {
          // Konwertuj urgency z enum (liczba) na string
          String urgencyStr = 'Medium';
          if (issue['urgency'] != null) {
            final urgencyValue = issue['urgency'];
            if (urgencyValue is int) {
              switch (urgencyValue) {
                case 0:
                  urgencyStr = 'Low';
                  break;
                case 1:
                  urgencyStr = 'Medium';
                  break;
                case 2:
                  urgencyStr = 'High';
                  break;
                case 3:
                  urgencyStr = 'Critical';
                  break;
                default:
                  urgencyStr = 'Medium';
              }
            } else {
              urgencyStr = urgencyValue.toString();
            }
          }
          
          // Konwertuj status z enum (liczba) na string
          String statusStr = 'New';
          if (issue['status'] != null) {
            final statusValue = issue['status'];
            if (statusValue is int) {
              switch (statusValue) {
                case 0:
                  statusStr = 'New';
                  break;
                case 1:
                  statusStr = 'InProgress';
                  break;
                case 2:
                  statusStr = 'Resolved';
                  break;
                case 3:
                  statusStr = 'Closed';
                  break;
                default:
                  statusStr = 'New';
              }
            } else {
              statusStr = statusValue.toString();
            }
          }
          
          return {
            'id': issue['id'] is int ? issue['id'] : int.tryParse(issue['id']?.toString() ?? '') ?? 0,
            'propertyId': issue['propertyId'] is int ? issue['propertyId'] : int.tryParse(issue['propertyId']?.toString() ?? '') ?? 0,
            'tenantId': issue['tenantId'] is int ? issue['tenantId'] : int.tryParse(issue['tenantId']?.toString() ?? '') ?? 0,
            'title': issue['title']?.toString() ?? '',
            'description': issue['description']?.toString() ?? '',
            'status': statusStr,
            'urgency': urgencyStr,
            'createdAt': issue['createdAt'] != null ? DateTime.parse(issue['createdAt'].toString()) : DateTime.now(),
            'resolvedAt': issue['resolvedAt'] != null ? DateTime.parse(issue['resolvedAt'].toString()) : null,
          };
        }).toList();
      } else {
        throw Exception('Failed to load issues: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting issues: $e');
    }
  }

  // Aktualizuj status problemu
  Future<Map<String, dynamic>> updateIssueStatus(int issueId, String status) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      // Mapuj string na enum value
      int statusValue;
      switch (status.toLowerCase()) {
        case 'new':
          statusValue = 0;
          break;
        case 'inprogress':
          statusValue = 1;
          break;
        case 'resolved':
          statusValue = 2;
          break;
        case 'closed':
          statusValue = 3;
          break;
        default:
          statusValue = 0;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/Issue/$issueId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(statusValue),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Konwertuj status z liczby na string
        String statusStr = 'New';
        if (data['status'] != null) {
          final statusValue = data['status'];
          if (statusValue is int) {
            switch (statusValue) {
              case 0:
                statusStr = 'New';
                break;
              case 1:
                statusStr = 'InProgress';
                break;
              case 2:
                statusStr = 'Resolved';
                break;
              case 3:
                statusStr = 'Closed';
                break;
              default:
                statusStr = 'New';
            }
          } else {
            statusStr = statusValue.toString();
          }
        }
        
        return {
          'id': data['id'] is int ? data['id'] : int.tryParse(data['id']?.toString() ?? '') ?? 0,
          'propertyId': data['propertyId'] is int ? data['propertyId'] : int.tryParse(data['propertyId']?.toString() ?? '') ?? 0,
          'tenantId': data['tenantId'] is int ? data['tenantId'] : int.tryParse(data['tenantId']?.toString() ?? '') ?? 0,
          'title': data['title']?.toString() ?? '',
          'description': data['description']?.toString() ?? '',
          'status': statusStr,
          'urgency': data['urgency']?.toString() ?? 'Medium',
          'createdAt': data['createdAt'] != null ? DateTime.parse(data['createdAt'].toString()) : DateTime.now(),
          'resolvedAt': data['resolvedAt'] != null ? DateTime.parse(data['resolvedAt'].toString()) : null,
        };
      } else {
        throw Exception('Failed to update issue status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating issue status: $e');
    }
  }
}


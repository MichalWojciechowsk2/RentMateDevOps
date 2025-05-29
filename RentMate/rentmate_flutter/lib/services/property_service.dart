import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property.dart';
import 'auth_service.dart';

class PropertyService {
  final String _baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  Future<List<Property>> getMyProperties() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Property'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load properties: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load properties: $e');
    }
  }

  Future<Property> getPropertyDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Property/$id'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return Property.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load property details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load property details: $e');
    }
  }

  Future<Property> createProperty(Property property) async {
    try {
      // Przygotuj dane do wysłania
      final propertyData = {
        'title': property.title,
        'description': property.description,
        'basePrice': property.basePrice,
        'baseDeposit': property.baseDeposit,
        'address': property.address,
        'city': property.city,
        'postalCode': property.postalCode,
        'roomCount': property.roomCount,
        'area': property.area,
        'isActive': property.isActive,
        'images': property.images,
      };

      print('Sending property data: ${json.encode(propertyData)}'); // Debug print

      final response = await http.post(
        Uri.parse('$_baseUrl/Property'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${await _authService.getToken()}',
        },
        body: json.encode(propertyData),
      );

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.body.isEmpty) {
          // Jeśli serwer zwraca pustą odpowiedź, ale status jest OK, zwróć oryginalny obiekt
          print('Server returned empty response, returning original property');
          return property;
        }
        return Property.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create property: ${response.body}');
      }
    } catch (e) {
      print('Error creating property: $e'); // Debug print
      throw Exception('Failed to create property: $e');
    }
  }

  Future<Property> updateProperty(Property property) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/Property/${property.id}'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${await _authService.getToken()}',
        },
        body: json.encode(property.toJson()),
      );

      if (response.statusCode == 200) {
        return Property.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update property: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update property: $e');
    }
  }

  Future<void> deleteProperty(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/Property/$id'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete property: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  Future<String> uploadImage(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/Property/upload-image'),
      );

      request.headers.addAll({
        // 'Authorization': 'Bearer ${await _authService.getToken()}',
      });

      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data['imageUrl'];
      } else {
        throw Exception('Failed to upload image: $responseBody');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
} 
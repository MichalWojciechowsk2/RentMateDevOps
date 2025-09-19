import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/property.dart';
import '../models/property_image.dart';
import 'auth_service.dart';

class PropertyService {
  final String _baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  Future<List<Property>> getMyProperties() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Property/my-properties'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
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
          'Authorization': 'Bearer ${await _authService.getToken()}',
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
        'district': property.district,
        'postalCode': property.postalCode,
        'roomCount': property.roomCount,
        'area': property.area,
        'isActive': property.isActive,
        'images': property.images,
        'ownerUsername': property.ownerUsername,
      };

      print('Sending property data: ${json.encode(propertyData)}'); // Debug print

      final response = await http.post(
        Uri.parse('$_baseUrl/Property'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
        body: json.encode(propertyData),
      );

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 201 || response.statusCode == 200) {
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
          'Authorization': 'Bearer ${await _authService.getToken()}',
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
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete property: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  Future<List<PropertyImage>> uploadImages(int propertyId, List<XFile> imageFiles) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/Property/$propertyId/images'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${await _authService.getToken()}',
      });

      for (XFile imageFile in imageFiles) {
        if (kIsWeb) {
          // For web, use bytes with proper content type
          final bytes = await imageFile.readAsBytes();
          String contentType = 'image/jpeg'; // default
          
          // Detect content type based on file extension
          final extension = imageFile.name.toLowerCase().split('.').last;
          switch (extension) {
            case 'png':
              contentType = 'image/png';
              break;
            case 'jpg':
            case 'jpeg':
              contentType = 'image/jpeg';
              break;
            case 'gif':
              contentType = 'image/gif';
              break;
            default:
              contentType = 'image/jpeg';
          }
          
          request.files.add(http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: imageFile.name,
            contentType: MediaType.parse(contentType),
          ));
        } else {
          // For mobile, use path
          request.files.add(await http.MultipartFile.fromPath('images', imageFile.path));
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(responseBody);
        return data.map((json) => PropertyImage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to upload images: $responseBody');
      }
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  Future<void> deleteImage(int imageId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/Property/images/$imageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  Future<List<String>> getCities() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Property/cities'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((city) => city['name'].toString()).toList();
    } else {
      throw Exception('Failed to load cities: \\${response.body}');
    }
  }

  Future<List<Property>> searchProperties({String? city, double? priceFrom, double? priceTo, int? rooms}) async {
    final queryParams = <String, String>{};
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (priceFrom != null) queryParams['priceFrom'] = priceFrom.toString();
    if (priceTo != null) queryParams['priceTo'] = priceTo.toString();
    if (rooms != null) queryParams['rooms'] = rooms.toString();
    final uri = Uri.parse('$_baseUrl/Property/filter').replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Property.fromJson(json)).toList();
    } else {
      throw Exception('Failed to filter properties: ${response.body}');
    }
  }

  Future<List<Property>> getAllProperties() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Property'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all properties: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load all properties: $e');
    }
  }
} 
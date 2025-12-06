import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'auth_service.dart';
import '../models/user.dart';

class UserService {
  final String _baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  Future<String> uploadUserPhoto(Uint8List imageBytes) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/User/uploadUserPhoto'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Determine content type
      String contentType = 'image/jpeg';
      String filename = 'photo.jpg';
      
      // Try to detect the image type based on bytes
      if (imageBytes.length >= 8) {
        // Check for PNG signature
        if (imageBytes[0] == 0x89 && imageBytes[1] == 0x50 && imageBytes[2] == 0x4E && imageBytes[3] == 0x47) {
          contentType = 'image/png';
          filename = 'photo.png';
        }
        // Check for GIF signature
        else if (imageBytes[0] == 0x47 && imageBytes[1] == 0x49 && imageBytes[2] == 0x46) {
          contentType = 'image/gif';
          filename = 'photo.gif';
        }
        // JPEG is the default
      }

      // Add image file with proper content type
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          imageBytes,
          filename: filename,
          contentType: MediaType.parse(contentType),
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Failed to upload photo: ${response.body}');
      }
      
      // The response is a file path, not JSON
      String responseBody = response.body;
      
      // Remove quotes if present
      if (responseBody.startsWith('"') && responseBody.endsWith('"')) {
        responseBody = responseBody.substring(1, responseBody.length - 1);
      }
      
      // Extract photo URL from response - convert Windows path to URL path
      String photoUrl = responseBody;
      if (photoUrl.contains('\\uploads\\UserPhoto\\')) {
        photoUrl = photoUrl.replaceAll('\\', '/');
        // Extract the path part after UserPhoto
        photoUrl = photoUrl.substring(photoUrl.indexOf('/uploads/UserPhoto/'));
      } else if (photoUrl.contains('/uploads/UserPhoto/')) {
        photoUrl = photoUrl.substring(photoUrl.indexOf('/uploads/UserPhoto/'));
      }
      
      return photoUrl;
    } catch (e) {
      throw Exception('Error uploading photo: $e');
    }
  }

  Future<User> getUserById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/User/getUserById?id=$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }
}


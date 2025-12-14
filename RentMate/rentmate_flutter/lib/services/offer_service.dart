import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/offer.dart';
import 'auth_service.dart';

class OfferService {
  final String _baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  Future<Offer> createOffer(CreateOfferDto dto) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Offer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
        body: json.encode(dto.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend zwraca { message: "Offer and contract generated successfully", offerId: ... }
        final responseData = json.decode(response.body);
        final offerId = responseData['offerId'] as int?;
        
        if (offerId != null) {
          // Pobierz utworzoną ofertę
          final offerResponse = await http.get(
            Uri.parse('$_baseUrl/Offer/getOffersByPropertyId?propertyId=${dto.propertyId}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${await _authService.getToken()}',
            },
          );
          
          if (offerResponse.statusCode == 200) {
            final List<dynamic> offers = json.decode(offerResponse.body);
            try {
              final createdOffer = offers.firstWhere((o) => (o['id'] is int ? o['id'] : int.tryParse(o['id']?.toString() ?? '') ?? 0) == offerId);
              return Offer.fromJson(createdOffer);
            } catch (e) {
              // Oferta nie została znaleziona w liście
            }
          }
        }
        
        // Fallback - zwróć podstawową ofertę z ID
        return Offer(
          id: offerId ?? 0,
          propertyId: dto.propertyId,
          rentAmount: dto.rentAmount,
          depositAmount: dto.depositAmount,
          rentalPeriodStart: dto.rentalPeriodStart,
          rentalPeriodEnd: dto.rentalPeriodEnd,
          status: OfferStatus.active,
          tenantId: dto.tenantId,
          createdAt: DateTime.now(),
        );
      } else {
        throw Exception('Failed to create offer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create offer: $e');
    }
  }

  Future<void> uploadContractPdf(int offerId, File? pdfFile, Uint8List? pdfBytes) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/Offer/$offerId/uploadContractPdf'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${await _authService.getToken()}',
      });

      if (kIsWeb && pdfBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'pdfFile',
          pdfBytes,
          filename: 'contract.pdf',
          contentType: MediaType('application', 'pdf'),
        ));
      } else if (pdfFile != null) {
        request.files.add(await http.MultipartFile.fromPath('pdfFile', pdfFile.path));
      } else {
        throw Exception('No PDF file provided');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Failed to upload PDF: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload PDF: $e');
    }
  }

  Future<List<Offer>> getOffersByPropertyId(int propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Offer/getOffersByPropertyId?propertyId=$propertyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Offer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load offers: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load offers: $e');
    }
  }

  // Pobierz aktywne i zaakceptowane oferty dla mieszkania
  Future<List<Offer>> getActiveAndAcceptedOffersByPropertyId(int propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Offer/getActiveAndAcceptedOffersByPropId?propertyId=$propertyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Offer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load offers: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load offers: $e');
    }
  }

  Future<List<Offer>> getOffersByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Offer/getOfferByUserId?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Offer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load offers: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load offers: $e');
    }
  }

  Future<void> acceptOffer(int offerId) async {
    try {
      // W C# enum OfferStatus: Active=0, Accepted=1, Completed=2, Cancelled=3
      // Wysyłamy wartość enum jako liczbę
      final response = await http.patch(
        Uri.parse('$_baseUrl/Offer/$offerId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
        body: json.encode(1), // Accepted = 1
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to accept offer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to accept offer: $e');
    }
  }

  Future<void> declineOffer(int offerId) async {
    try {
      // W C# enum OfferStatus: Active=0, Accepted=1, Completed=2, Cancelled=3
      // Wysyłamy wartość enum jako liczbę
      final response = await http.patch(
        Uri.parse('$_baseUrl/Offer/$offerId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
        body: json.encode(3), // Cancelled = 3
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to decline offer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to decline offer: $e');
    }
  }

  Future<Offer?> getAcceptedOffer(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Offer/getAcceptedOfferByUserId?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Offer.fromJson(data);
      } else if (response.statusCode == 404) {
        // Brak zaakceptowanej oferty - to OK
        return null;
      } else {
        throw Exception('Failed to load accepted offer: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('NotFound')) {
        return null;
      }
      throw Exception('Failed to load accepted offer: $e');
    }
  }

  // Sprawdź czy użytkownik ma aktywną ofertę dla danego mieszkania
  Future<bool> hasActiveOfferForProperty(int propertyId) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return false;
      
      final userId = int.tryParse(currentUser.id);
      if (userId == null) return false;
      
      final offers = await getOffersByUserId(userId);
      return offers.any((offer) => 
        offer.propertyId == propertyId && 
        offer.status == OfferStatus.accepted
      );
    } catch (e) {
      return false;
    }
  }

}



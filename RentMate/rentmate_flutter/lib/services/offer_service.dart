import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/offer.dart';
import 'auth_service.dart';

class OfferService {
  final String _baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  Future<void> createOffer(CreateOfferDto dto) async {
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
        // Backend zwraca { message: "Offer and contract generated successfully" }
        // Oferta została utworzona i powiadomienie wysłane
        return;
      } else {
        throw Exception('Failed to create offer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create offer: $e');
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



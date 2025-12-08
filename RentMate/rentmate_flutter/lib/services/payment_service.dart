import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PaymentService {
  static const String baseUrl = 'https://localhost:7281/api';
  final AuthService _authService = AuthService();

  // Utwórz rachunek
  Future<bool> createPayment({
    required int propertyId,
    required int offerId,
    required double amount,
    required String description,
    required DateTime dueDate,
    required String paymentMethod,
    bool generateWithRecurring = false,
    int? recurrenceTimes,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/Payment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'propertyId': propertyId,
          'offerId': offerId,
          'amount': amount,
          'description': description,
          'dueDate': dueDate.toIso8601String(),
          'paymentMethod': paymentMethod,
          'generateWithRecurring': generateWithRecurring,
          'recurrenceTimes': recurrenceTimes,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to create payment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }

  // Pobierz rachunki dla najemcy (aktywne oferty)
  Future<List<Map<String, dynamic>>> getPaymentsByActiveUserOffers() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Payment/getPaymentsByActiveUserOffers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((payment) {
          return {
            'id': payment['id'] is int ? payment['id'] : int.tryParse(payment['id']?.toString() ?? '') ?? 0,
            'offerId': payment['offerId'] is int ? payment['offerId'] : int.tryParse(payment['offerId']?.toString() ?? '') ?? 0,
            'tenantId': payment['tenantId'] is int ? payment['tenantId'] : int.tryParse(payment['tenantId']?.toString() ?? '') ?? 0,
            'amount': payment['amount'] is double ? payment['amount'] : double.tryParse(payment['amount']?.toString() ?? '') ?? 0.0,
            'description': payment['description']?.toString() ?? '',
            'status': payment['status']?.toString() ?? 'Pending',
            'dueDate': payment['dueDate'] != null ? DateTime.parse(payment['dueDate'].toString()) : null,
            'paidAt': payment['paidAt'] != null ? DateTime.parse(payment['paidAt'].toString()) : null,
            'paymentMethod': payment['paymentMethod']?.toString() ?? '',
            'tenantName': payment['tenantName']?.toString() ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load payments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting payments: $e');
    }
  }

  // Pobierz rachunki dla mieszkania
  Future<List<Map<String, dynamic>>> getPaymentsByProperty(int propertyId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Payment/getAllPaymentsForPropertyByActiveUserOffers?propertyId=$propertyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((payment) {
          return {
            'id': payment['id'] is int ? payment['id'] : int.tryParse(payment['id']?.toString() ?? '') ?? 0,
            'offerId': payment['offerId'] is int ? payment['offerId'] : int.tryParse(payment['offerId']?.toString() ?? '') ?? 0,
            'tenantId': payment['tenantId'] is int ? payment['tenantId'] : int.tryParse(payment['tenantId']?.toString() ?? '') ?? 0,
            'amount': payment['amount'] is double ? payment['amount'] : double.tryParse(payment['amount']?.toString() ?? '') ?? 0.0,
            'description': payment['description']?.toString() ?? '',
            'status': payment['status']?.toString() ?? 'Pending',
            'dueDate': payment['dueDate'] != null ? DateTime.parse(payment['dueDate'].toString()) : null,
            'paidAt': payment['paidAt'] != null ? DateTime.parse(payment['paidAt'].toString()) : null,
            'paymentMethod': payment['paymentMethod']?.toString() ?? '',
            'tenantName': payment['tenantName']?.toString() ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load payments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting payments: $e');
    }
  }

  // Pobierz ostatnie 10 rachunków dla mieszkania
  Future<List<Map<String, dynamic>>> getLastPaymentsForProperty(int propertyId, {int count = 10}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/Payment/getLastPaymentsForProperty?propertyId=$propertyId&count=$count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((payment) {
          return {
            'id': payment['id'] is int ? payment['id'] : int.tryParse(payment['id']?.toString() ?? '') ?? 0,
            'offerId': payment['offerId'] is int ? payment['offerId'] : int.tryParse(payment['offerId']?.toString() ?? '') ?? 0,
            'tenantId': payment['tenantId'] is int ? payment['tenantId'] : int.tryParse(payment['tenantId']?.toString() ?? '') ?? 0,
            'amount': payment['amount'] is double ? payment['amount'] : double.tryParse(payment['amount']?.toString() ?? '') ?? 0.0,
            'description': payment['description']?.toString() ?? '',
            'status': payment['status']?.toString() ?? 'Pending',
            'dueDate': payment['dueDate'] != null ? DateTime.parse(payment['dueDate'].toString()) : null,
            'paidAt': payment['paidAt'] != null ? DateTime.parse(payment['paidAt'].toString()) : null,
            'paymentMethod': payment['paymentMethod']?.toString() ?? '',
            'tenantName': payment['tenantName']?.toString() ?? '',
            'tenantSurname': payment['tenantSurname']?.toString() ?? '',
            'createDateTime': payment['createDateTime'] != null ? DateTime.parse(payment['createDateTime'].toString()) : null,
          };
        }).toList();
      } else {
        throw Exception('Failed to load payments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting payments: $e');
    }
  }

  // Oznacz rachunek jako zapłacony/niezapłacony
  Future<bool> markPaymentAsPaid(int paymentId, bool isPaid) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.patch(
        Uri.parse('$baseUrl/Payment/markAsPaid?paymentId=$paymentId&isPaid=$isPaid'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update payment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating payment: $e');
    }
  }
}



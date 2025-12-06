import 'package:flutter/material.dart';
import '../models/property.dart';
import '../models/offer.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/property_service.dart';
import '../services/offer_service.dart';
import '../services/message_service.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import 'my_apartment_chat_tab.dart';
import 'my_apartment_payments_tab.dart';
import 'my_apartment_issues_tab.dart';

class MyApartmentScreen extends StatefulWidget {
  final Offer acceptedOffer;
  final int? initialTabIndex;

  const MyApartmentScreen({super.key, required this.acceptedOffer, this.initialTabIndex});

  @override
  State<MyApartmentScreen> createState() => _MyApartmentScreenState();
}

class _MyApartmentScreenState extends State<MyApartmentScreen> with SingleTickerProviderStateMixin {
  final _propertyService = PropertyService();
  final _messageService = MessageService();
  final _authService = AuthService();
  final _paymentService = PaymentService();
  late TabController _tabController;

  Property? _property;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTabIndex ?? 0;
    _tabController = TabController(length: 3, vsync: this, initialIndex: initialIndex);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadCurrentUser(),
        _loadProperty(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania danych: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadProperty() async {
    try {
      final property = await _propertyService.getPropertyDetails(widget.acceptedOffer.propertyId);
      setState(() {
        _property = property;
      });
    } catch (e) {
      print('Failed to load property: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Moje mieszkanie'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_property?.title ?? 'Moje mieszkanie'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: 'Czat'),
            Tab(icon: Icon(Icons.receipt), text: 'Rachunki'),
            Tab(icon: Icon(Icons.report_problem), text: 'Problemy'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Informacje o mieszkaniu
          if (_property != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _property!.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_property!.city}, ${_property!.district}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.bed, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text('${_property!.roomCount} pokoi'),
                      const SizedBox(width: 16),
                      Icon(Icons.square_foot, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text('${_property!.area} m²'),
                    ],
                  ),
                ],
              ),
            ),
          // Zakładki
          Expanded(
            child: _property != null
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      MyApartmentChatTab(
                        property: _property!,
                        currentUser: _currentUser,
                      ),
                      MyApartmentPaymentsTab(
                        property: _property!,
                        acceptedOffer: widget.acceptedOffer,
                      ),
                      MyApartmentIssuesTab(
                        property: _property!,
                        acceptedOffer: widget.acceptedOffer,
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}


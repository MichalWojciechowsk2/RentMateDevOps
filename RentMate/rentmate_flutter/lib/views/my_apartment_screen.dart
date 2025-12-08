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
import '../services/review_service.dart';
import '../models/review.dart';
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
  final _reviewService = ReviewService();
  late TabController _tabController;

  Property? _property;
  User? _currentUser;
  bool _isLoading = true;
  bool _hasReviewed = false;
  List<Review> _propertyReviews = [];
  double _averageRating = 0.0;

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
      await _loadPropertyReviews();
    } catch (e) {
      print('Failed to load property: $e');
    }
  }

  Future<void> _loadPropertyReviews() async {
    if (_property == null || _currentUser == null) return;
    try {
      final reviews = await _reviewService.getReviewsForProperty(_property!.id);
      setState(() {
        _propertyReviews = reviews;
        if (reviews.isNotEmpty) {
          final sum = reviews.fold<double>(0.0, (sum, review) => sum + review.rating);
          _averageRating = sum / reviews.length;
        }
      });
      
      // Sprawdź czy użytkownik już wystawił recenzję
      final userId = int.tryParse(_currentUser!.id);
      if (userId != null) {
        final hasReviewed = reviews.any((review) => review.authorId == userId);
        setState(() {
          _hasReviewed = hasReviewed;
        });
      }
    } catch (e) {
      // Ignoruj błędy
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _property!.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_averageRating > 0) ...[
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              _averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${_propertyReviews.length})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (!_hasReviewed) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showPropertyReviewDialog(),
                        icon: const Icon(Icons.star),
                        label: const Text('Wystaw recenzję mieszkania'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
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

  Future<void> _showPropertyReviewDialog() async {
    final formKey = GlobalKey<FormState>();
    final commentController = TextEditingController();
    int selectedRating = 0;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Wystaw recenzję mieszkania'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ocena:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedRating = index + 1;
                          });
                        },
                        child: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Komentarz (opcjonalnie)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    maxLength: 1000,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedRating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Proszę wybrać ocenę'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                try {
                  await _reviewService.createReview(
                    CreateReviewDto(
                      propertyId: _property!.id,
                      rating: selectedRating.toDouble(),
                      comment: commentController.text.trim(),
                    ),
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recenzja została dodana'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    await _loadPropertyReviews();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Błąd podczas dodawania recenzji: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Wyślij'),
            ),
          ],
        ),
      ),
    );
  }
}


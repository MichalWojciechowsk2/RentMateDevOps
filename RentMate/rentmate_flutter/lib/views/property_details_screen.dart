import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/property.dart';
import '../models/user.dart';
import '../services/property_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/offer_service.dart';
import '../services/review_service.dart';
import '../models/review.dart';
import 'chat_screen.dart';
import 'tenant_profile_view.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final int propertyId;
  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final _propertyService = PropertyService();
  final _authService = AuthService();
  final _userService = UserService();
  final _offerService = OfferService();
  final _reviewService = ReviewService();
  bool _isLoading = true;
  Property? _property;
  bool _isOwner = false;
  bool _hasActiveOffer = false;
  bool _hasReviewed = false;
  List<Review> _propertyReviews = [];
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  Future<void> _loadPropertyDetails() async {
    setState(() => _isLoading = true);
    try {
      final property = await _propertyService.getPropertyDetails(widget.propertyId);
      setState(() {
        _property = property;
      });
      await _checkOwnership();
      await _checkActiveOffer();
      await _loadPropertyReviews();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load property details: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context); // Powrót, jeśli nie udało się załadować
      }
    }
  }

  Future<void> _checkActiveOffer() async {
    if (_property == null) return;
    try {
      final hasOffer = await _offerService.hasActiveOfferForProperty(_property!.id);
      setState(() {
        _hasActiveOffer = hasOffer;
      });
    } catch (e) {
      // Ignoruj błędy
    }
  }

  Future<void> _loadPropertyReviews() async {
    if (_property == null) return;
    try {
      final reviews = await _reviewService.getReviewsForProperty(_property!.id);
      setState(() {
        _propertyReviews = reviews;
        if (reviews.isNotEmpty) {
          final sum = reviews.fold<double>(0.0, (sum, review) => sum + review.rating);
          _averageRating = sum / reviews.length;
        }
      });
      
      // Sprawdź czy użytkownik już wystawił recenzję (po załadowaniu recenzji)
      if (_hasActiveOffer && !_isOwner) {
        final currentUser = await _authService.getCurrentUser();
        if (currentUser != null) {
          final userId = int.tryParse(currentUser.id);
          if (userId != null) {
            final hasReviewed = reviews.any((review) => review.authorId == userId);
            setState(() {
              _hasReviewed = hasReviewed;
            });
          }
        }
      }
    } catch (e) {
      // Ignoruj błędy
    }
  }


  Future<void> _showOwnerProfile() async {
    if (_property == null) return;
    
    try {
      final owner = await _userService.getUserById(_property!.ownerId);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => TenantProfileView(
            tenant: owner,
            propertyId: widget.propertyId,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania profilu właściciela: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkOwnership() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser != null && _property != null) {
      setState(() {
        _isOwner = int.tryParse(currentUser.id) == _property!.ownerId;
      });
    }
  }

  Future<void> _deleteProperty() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: const Text('Are you sure you want to delete this property?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _propertyService.deleteProperty(_property!.id);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        actions: [
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  '/edit-property',
                  arguments: _property,
                );
                if (mounted) {
                  // Po edycji, ponownie załaduj szczegóły nieruchomości
                  _loadPropertyDetails();
                }
              },
            ),
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteProperty,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _property == null
              ? const Center(child: Text('Property not found.'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_property!.images.isNotEmpty)
                        FlutterCarousel(
                          options: CarouselOptions(
                            height: 300,
                            viewportFraction: 1.0,
                            enableInfiniteScroll: _property!.images.length > 1,
                            autoPlay: _property!.images.length > 1,
                          ),
                          items: _property!.images.map((propertyImage) {
                            final imageUrl = 'https://localhost:7281${propertyImage.imageUrl}';
                            print('Loading image from: $imageUrl'); // Debug print
                            return CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                print('Error loading image: $error'); // Debug print
                                return Container(
                                  color: Colors.grey[300],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error,
                                        color: Colors.grey,
                                        size: 50,
                                      ),
                                      Text(
                                        'Error: $error',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        )
                      else
                        Container(
                          height: 300,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.home,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _property!.title,
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                ),
                                if (_averageRating > 0) ...[
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 24),
                                      const SizedBox(width: 4),
                                      Text(
                                        _averageRating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${_propertyReviews.length})',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            if (_hasActiveOffer && !_hasReviewed && !_isOwner) ...[
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
                            const SizedBox(height: 8),
                            Text(
                              '\$${_property!.basePrice.toStringAsFixed(2)} per month',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _property!.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _property!.district.isNotEmpty
                                  ? '${_property!.address}, ${_property!.district}, ${_property!.city}, ${_property!.postalCode}'
                                  : '${_property!.address}, ${_property!.city}, ${_property!.postalCode}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    Icons.door_front_door,
                                    '${_property!.roomCount} Rooms',
                                  ),
                                ),
                                Expanded(
                                  child: _buildDetailItem(
                                    Icons.square_foot,
                                    '${_property!.area} m²',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    Icons.attach_money,
                                    'Base Deposit: \$${_property!.baseDeposit.toStringAsFixed(2)}',
                                  ),
                                ),
                              ],
                            ),
                            if (_property!.ownerPhoneNumber != null && _property!.ownerPhoneNumber!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDetailItem(
                                      Icons.phone,
                                      _property!.ownerPhoneNumber!,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 24),
                            // Owner Profile Section - tylko dla użytkowników, którzy nie są właścicielem
                            if (!_isOwner) ...[
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showOwnerProfile(),
                                  icon: const Icon(Icons.person),
                                  label: Text('Zobacz profil właściciela: ${_property!.ownerUsername ?? "Właściciel"}'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          otherUserId: _property!.ownerId,
                                          otherUsername: _property!.ownerUsername ?? 'Property Owner',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Contact Owner'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
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
                    await _checkActiveOffer();
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
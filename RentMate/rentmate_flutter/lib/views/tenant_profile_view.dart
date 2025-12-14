import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../services/auth_service.dart';

class TenantProfileView extends StatefulWidget {
  final User tenant;
  final int propertyId;

  const TenantProfileView({
    super.key,
    required this.tenant,
    required this.propertyId,
  });

  @override
  State<TenantProfileView> createState() => _TenantProfileViewState();
}

class _TenantProfileViewState extends State<TenantProfileView> {
  final _reviewService = ReviewService();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  List<Review> _reviews = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  double _selectedRating = 0;
  bool _canSubmitReview = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = await _authService.getCurrentUser();
      setState(() {
        _currentUserId = currentUser != null ? int.tryParse(currentUser.id) : null;
      });

      final reviews = await _reviewService.getReviewsForUser(int.parse(widget.tenant.id));
      
      // Sprawdź czy użytkownik już wystawił ocenę
      if (_currentUserId != null) {
        final hasReviewed = reviews.any((review) => review.authorId == _currentUserId);
        setState(() {
          _canSubmitReview = !hasReviewed;
        });
      }

      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania danych: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proszę wybrać ocenę'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _reviewService.createReview(
        CreateReviewDto(
          userId: int.parse(widget.tenant.id),
          rating: _selectedRating,
          comment: _commentController.text.trim().isEmpty 
              ? '' 
              : _commentController.text.trim(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocena została dodana'),
            backgroundColor: Colors.green,
          ),
        );
        _commentController.clear();
        _selectedRating = 0;
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas dodawania oceny: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  double _calculateAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    final sum = _reviews.fold<double>(0.0, (sum, review) => sum + review.rating);
    return sum / _reviews.length;
  }

  String _getPhotoUrl() {
    final photoUrl = widget.tenant.photoUrl ?? widget.tenant.profilePictureUrl;
    if (photoUrl == null || photoUrl.isEmpty) {
      return 'https://localhost:7281/uploads/UserPhoto/defaultPersonPhoto.png';
    }
    if (photoUrl.startsWith('http')) {
      return photoUrl;
    }
    return 'https://localhost:7281$photoUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Profil użytkownika',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Photo and Basic Info
                            Center(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: CachedNetworkImageProvider(_getPhotoUrl()),
                                    onBackgroundImageError: (_, __) {},
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${widget.tenant.firstName} ${widget.tenant.lastName}',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${widget.tenant.id}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  if (widget.tenant.email.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.tenant.email,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Contact Info
                            if (widget.tenant.phoneNumber.isNotEmpty) ...[
                              _buildInfoRow(Icons.phone, widget.tenant.phoneNumber),
                              const SizedBox(height: 8),
                            ],
                            // About Me
                            if (widget.tenant.aboutMe != null && widget.tenant.aboutMe!.isNotEmpty) ...[
                              const Text(
                                'O mnie',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.tenant.aboutMe!,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 24),
                            ],
                            // Ratings Section
                            const Divider(),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text(
                                  'Oceny',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (_reviews.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        _calculateAverageRating().toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${_reviews.length})',
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
                            const SizedBox(height: 16),
                            // Reviews List
                            if (_reviews.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text('Brak ocen'),
                                ),
                              )
                            else
                              ..._reviews.map((review) => _buildReviewCard(review)),
                            const SizedBox(height: 16),
                            // Submit Review Form
                            if (_canSubmitReview && _currentUserId != null && int.parse(widget.tenant.id) != _currentUserId) ...[
                              const Divider(),
                              const SizedBox(height: 16),
                              const Text(
                                'Wystaw ocenę',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Ocena:'),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: List.generate(5, (index) {
                                        final rating = index + 1;
                                        return IconButton(
                                          icon: Icon(
                                            _selectedRating >= rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 32,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _selectedRating = rating.toDouble();
                                            });
                                          },
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _commentController,
                                      decoration: const InputDecoration(
                                        labelText: 'Komentarz (opcjonalnie)',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 3,
                                      maxLength: 1000,
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isSubmitting ? null : _submitReview,
                                        child: _isSubmitting
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Text('Dodaj ocenę'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    final authorName = review.author != null
        ? '${review.author!['firstName'] ?? ''} ${review.author!['lastName'] ?? ''}'.trim()
        : 'Anonimowy';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.comment),
            ],
            const SizedBox(height: 8),
            Text(
              _formatDate(review.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

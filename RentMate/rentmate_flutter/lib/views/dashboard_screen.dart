import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../views/my_chats_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _propertyService = PropertyService();
  final AuthService _authService = AuthService();
  List<Property> _properties = [];
  bool _isLoading = false;
  User? _currentUser;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  // Filtry
  List<String> _cities = [];
  String? _selectedCity;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _roomsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _loadProperties();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetchCities() async {
    try {
      final cities = await _propertyService.getCities();
      setState(() {
        _cities = cities;
      });
    } catch (e) {
      // Możesz dodać obsługę błędów
    }
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    try {
      final minPrice = _minPriceController.text.isNotEmpty ? double.tryParse(_minPriceController.text) : null;
      final maxPrice = _maxPriceController.text.isNotEmpty ? double.tryParse(_maxPriceController.text) : null;
      final rooms = _roomsController.text.isNotEmpty ? int.tryParse(_roomsController.text) : null;
      
      final result = await _propertyService.getAllProperties(
        pageNumber: _currentPage,
        pageSize: 10,
        city: _selectedCity,
        priceFrom: minPrice,
        priceTo: maxPrice,
        rooms: rooms,
      );
      setState(() {
        _properties = result['properties'] as List<Property>;
        _currentPage = result['pageNumber'] as int;
        _totalPages = result['totalPages'] as int;
        _totalItems = result['totalItems'] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _filterProperties() async {
    // Reset to page 1 when filtering
    setState(() {
      _currentPage = 1;
    });
    await _loadProperties();
  }

  void _resetFilters() {
    setState(() {
      _selectedCity = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      _roomsController.clear();
      _currentPage = 1;
    });
    _loadProperties();
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadProperties();
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _goToPage(_currentPage - 1);
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _roomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentUser != null
            ? GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: _currentUser!.photoUrl != null && _currentUser!.photoUrl!.isNotEmpty
                          ? NetworkImage('https://localhost:7281${_currentUser!.photoUrl}')
                          : null,
                      child: _currentUser!.photoUrl == null || _currentUser!.photoUrl!.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text('Hello, ${_currentUser!.firstName}'),
                  ],
                ),
              )
            : const Text('My Properties'),
        actions: [
          if (_currentUser?.role == 'Owner' || _currentUser?.role == 'Tenant')
            IconButton(
              icon: const Icon(Icons.message),
              tooltip: 'My Messages',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyChatsScreen()),
                );
              },
            ),
          if (_currentUser?.role == 'Owner')
            IconButton(
              icon: const Icon(Icons.home_work),
              onPressed: () async {
                await Navigator.pushNamed(context, '/my-properties');
                _loadProperties();
              },
            ),
          if (_currentUser?.role == 'Owner')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.pushNamed(context, '/add-property');
                _loadProperties();
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCity,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('-- Wybierz miasto --')),
                          ..._cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                        ],
                        onChanged: (value) => setState(() => _selectedCity = value),
                        decoration: const InputDecoration(labelText: 'Miasto'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Min. cena (zł)'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Max. cena (zł)'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _roomsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Liczba pokoi'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _filterProperties,
                      child: const Text('Filtruj'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _resetFilters,
                      child: const Text('Resetuj'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _properties.isEmpty
                    ? const Center(
                        child: Text(
                          'No properties found. Add your first property!',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: _loadProperties,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _properties.length,
                                itemBuilder: (context, index) {
                                  final property = _properties[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/property-details',
                                          arguments: property.id,
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (property.mainImageUrl != null)
                                            Builder(
                                              builder: (context) {
                                                final imageUrl = 'https://localhost:7281${property.mainImageUrl}';
                                                print('Loading property image from: $imageUrl');
                                                return SizedBox(
                                                  height: 200,
                                                  width: double.infinity,
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Container(
                                                        color: Colors.grey[300],
                                                        child: const Center(
                                                          child: CircularProgressIndicator(),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context, error, stackTrace) {
                                                      print('Error loading image: $error for URL: $imageUrl');
                                                      return Container(
                                                        color: Colors.grey[300],
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.error,
                                                            color: Colors.grey,
                                                            size: 50,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            )
                                          else
                                            Container(
                                              height: 200,
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
                                                Text(
                                                  property.title,
                                                  style: Theme.of(context).textTheme.titleLarge,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '\$${property.basePrice.toStringAsFixed(2)} per month',
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${property.address}, ${property.city}',
                                                  style: Theme.of(context).textTheme.bodyLarge,
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: _buildDetailItem(
                                                        Icons.door_front_door,
                                                        '${property.roomCount} Rooms',
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: _buildDetailItem(
                                                        Icons.square_foot,
                                                        '${property.area} m²',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Pagination controls
                          if (_totalPages > 1)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _currentPage > 1 ? _previousPage : null,
                                    icon: const Icon(Icons.chevron_left),
                                    label: const Text('Poprzednia'),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Strona $_currentPage z $_totalPages',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: _currentPage < _totalPages ? _nextPage : null,
                                    icon: const Icon(Icons.chevron_right),
                                    label: const Text('Następna'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
          ),
        ],
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
} 
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/property.dart';
import '../services/property_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _propertyService = PropertyService();
  List<Property> _properties = [];
  bool _isLoading = false;

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
      final properties = await _propertyService.getMyProperties();
      setState(() {
        _properties = properties;
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
    setState(() => _isLoading = true);
    try {
      final minPrice = _minPriceController.text.isNotEmpty ? double.tryParse(_minPriceController.text) : null;
      final maxPrice = _maxPriceController.text.isNotEmpty ? double.tryParse(_maxPriceController.text) : null;
      final rooms = _roomsController.text.isNotEmpty ? int.tryParse(_roomsController.text) : null;
      final properties = await _propertyService.searchProperties(
        city: _selectedCity,
        priceFrom: minPrice,
        priceTo: maxPrice,
        rooms: rooms,
      );
      setState(() {
        _properties = properties;
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

  void _resetFilters() {
    setState(() {
      _selectedCity = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      _roomsController.clear();
    });
    _loadProperties();
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
        title: const Text('My Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, '/add-property');
              _loadProperties();
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
                    : RefreshIndicator(
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
                                    arguments: property,
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (property.images.isNotEmpty)
                                      SizedBox(
                                        height: 200,
                                        width: double.infinity,
                                        child: CachedNetworkImage(
                                          imageUrl: property.images.first,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.error,
                                              color: Colors.grey,
                                              size: 50,
                                            ),
                                          ),
                                        ),
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
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/property.dart';
import '../models/property_image.dart';
import '../services/property_service.dart';
import 'package:flutter/material.dart';

class EditPropertyScreen extends StatefulWidget {
  const EditPropertyScreen({super.key});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyService = PropertyService();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;
  late Property _property;
  List<PropertyImage> _currentImages = [];
  List<XFile> _newImages = [];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _baseDepositController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _roomCountController = TextEditingController();
  final _areaController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _property = ModalRoute.of(context)!.settings.arguments as Property;
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController.text = _property.title;
    _descriptionController.text = _property.description;
    _basePriceController.text = _property.basePrice.toString();
    _baseDepositController.text = _property.baseDeposit.toString();
    _addressController.text = _property.address;
    _cityController.text = _property.city;
    _districtController.text = _property.district;
    _postalCodeController.text = _property.postalCode;
    _roomCountController.text = _property.roomCount.toString();
    _areaController.text = _property.area;
    _currentImages = List.from(_property.images);
  }

  Future<void> _togglePublish() async {
    setState(() => _isLoading = true);
    try {
      final updated = await _propertyService.updatePropertyIsActive(_property.id, !_property.isActive);
      if (updated) {
        setState(() {
          _property = Property(
            id: _property.id,
            ownerId: _property.ownerId,
            title: _property.title,
            description: _property.description,
            basePrice: _property.basePrice,
            baseDeposit: _property.baseDeposit,
            address: _property.address,
            city: _property.city,
            district: _property.district,
            postalCode: _property.postalCode,
            roomCount: _property.roomCount,
            area: _property.area,
            images: _property.images,
            isActive: !_property.isActive,
            createdAt: _property.createdAt,
            updatedAt: DateTime.now(),
            ownerUsername: _property.ownerUsername,
          );
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_property.isActive ? 'Property published' : 'Property unpublished')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update property: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _newImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting images: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Widget> _buildImageWidget(XFile imageFile) async {
    if (kIsWeb) {
      // For web, use Image.memory with bytes from XFile
      final bytes = await imageFile.readAsBytes();
      return Image.memory(
        bytes,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[300],
            child: const Icon(
              Icons.error,
              color: Colors.grey,
            ),
          );
        },
      );
    } else {
      // For mobile, use Image.file
      return Image.file(
        File(imageFile.path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[300],
            child: const Icon(
              Icons.error,
              color: Colors.grey,
            ),
          );
        },
      );
    }
  }

  Future<void> _deleteExistingImage(PropertyImage image) async {
    if (await _showDeleteConfirmation()) {
      try {
        await _propertyService.deleteImage(image.id);
        setState(() {
          _currentImages.remove(image);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting image: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
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
    ) ?? false;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final updatedProperty = Property(
        id: _property.id,
        ownerId: _property.ownerId,
        title: _titleController.text,
        description: _descriptionController.text,
        basePrice: double.parse(_basePriceController.text),
        baseDeposit: double.parse(_baseDepositController.text),
        address: _addressController.text,
        city: _cityController.text,
        district: _districtController.text,
        postalCode: _postalCodeController.text,
        roomCount: int.parse(_roomCountController.text),
        area: _areaController.text,
        images: _currentImages, // Używamy obecnych zdjęć
        isActive: _property.isActive,
        createdAt: _property.createdAt,
        updatedAt: DateTime.now(),
        ownerUsername: _property.ownerUsername,
      );

      await _propertyService.updateProperty(updatedProperty);
      
      // Jeśli są nowe zdjęcia, upload je
      if (_newImages.isNotEmpty) {
        await _propertyService.uploadImages(_property.id, _newImages);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedProperty);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _baseDepositController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _postalCodeController.dispose();
    _roomCountController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Property'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _togglePublish,
            icon: Icon(_property.isActive ? Icons.visibility_off : Icons.publish),
            label: Text(_property.isActive ? 'Unpublish' : 'Publish'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // placeholder for rental contracts section
                      },
                      icon: const Icon(Icons.description),
                      label: const Text('Umowy wynajmu'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        // placeholder for bills section
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Rachunki'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _basePriceController,
                          decoration: const InputDecoration(
                            labelText: 'Base Price per month',
                            border: OutlineInputBorder(),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _baseDepositController,
                          decoration: const InputDecoration(
                            labelText: 'Base Deposit',
                            border: OutlineInputBorder(),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a deposit';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a city';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _districtController,
                    decoration: const InputDecoration(
                      labelText: 'District',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a district';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a postal code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _roomCountController,
                          decoration: const InputDecoration(
                            labelText: 'Number of Rooms',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter number of rooms';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _areaController,
                          decoration: const InputDecoration(
                            labelText: 'Area (m²)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter area';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Images',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Obecne zdjęcia z serwera
                  if (_currentImages.isNotEmpty) ...[
                    const Text('Current Images:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _currentImages.length,
                        itemBuilder: (context, index) {
                          final image = _currentImages[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: 'https://localhost:7281${image.imageUrl}',
                                    width: 100,
                                    height: 100,
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
                                      ),
                                    ),
                                  ),
                                ),
                                if (image.isMainImage)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Main',
                                        style: TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: IconButton(
                                    tooltip: image.isMainImage ? 'Main image' : 'Set as main',
                                    icon: Icon(
                                      image.isMainImage ? Icons.star : Icons.star_border,
                                      color: image.isMainImage ? Colors.amber : Colors.white,
                                    ),
                                    onPressed: image.isMainImage
                                        ? null
                                        : () async {
                                            try {
                                              await _propertyService.setMainImage(image.id);
                                              setState(() {
                                                _currentImages = _currentImages
                                                    .map((img) => PropertyImage(
                                                          id: img.id,
                                                          propertyId: img.propertyId,
                                                          imageUrl: img.imageUrl,
                                                          isMainImage: img.id == image.id,
                                                          createdAt: img.createdAt,
                                                        ))
                                                    .toList();
                                              });
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Main image updated')),
                                                );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                                );
                                              }
                                            }
                                          },
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () => _deleteExistingImage(image),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Nowe wybrane zdjęcia (lokalne)
                  if (_newImages.isNotEmpty) ...[
                    const Text('New Images to Upload:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _newImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FutureBuilder<Widget>(
                                    future: _buildImageWidget(_newImages[index]),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return snapshot.data!;
                                      } else {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _newImages.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Images'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }
} 
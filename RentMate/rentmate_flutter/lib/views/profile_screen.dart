import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _aboutMeController = TextEditingController();
  final _emailController = TextEditingController();
  
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  User? _currentUser;
  bool _isLoading = false;
  bool _isEditing = false;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _aboutMeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser != null) {
        _firstNameController.text = _currentUser!.firstName;
        _lastNameController.text = _currentUser!.lastName;
        _phoneNumberController.text = _currentUser!.phoneNumber ?? '';
        _aboutMeController.text = _currentUser!.aboutMe ?? '';
        _emailController.text = _currentUser!.email;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas ładowania profilu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = File(image.path);
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas wybierania zdjęcia: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      if (_currentUser == null) return;
      
      final userId = int.parse(_currentUser!.id);
      
      // Upload photo if selected
      if (_selectedImageBytes != null) {
        await _userService.uploadUserPhoto(_selectedImageBytes!);
      }
      
      // Update first name if changed
      final newFirstName = _firstNameController.text.trim();
      if (newFirstName != _currentUser!.firstName) {
        await _userService.updateUserField(userId, 'firstName', newFirstName);
      }
      
      // Update last name if changed
      final newLastName = _lastNameController.text.trim();
      if (newLastName != _currentUser!.lastName) {
        await _userService.updateUserField(userId, 'lastName', newLastName);
      }
      
      // Update phone number if changed
      final newPhoneNumber = _phoneNumberController.text.trim();
      if (newPhoneNumber != (_currentUser!.phoneNumber ?? '')) {
        await _userService.updateUserField(userId, 'phoneNumber', newPhoneNumber);
      }
      
      // Update AboutMe if changed
      final newAboutMe = _aboutMeController.text.trim();
      if (newAboutMe != (_currentUser!.aboutMe ?? '')) {
        await _userService.updateUserField(userId, 'aboutMe', newAboutMe);
      }
      
      // Reload user profile to get updated data
      await _loadUserProfile();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil został zaktualizowany pomyślnie')),
        );
        setState(() {
          _isEditing = false;
          _selectedImage = null;
          _selectedImageBytes = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas aktualizacji profilu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mój profil'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedImageBytes != null
                          ? (kIsWeb
                              ? MemoryImage(_selectedImageBytes!) as ImageProvider
                              : _selectedImage != null
                                  ? FileImage(_selectedImage!) as ImageProvider
                                  : null)
                          : _currentUser?.photoUrl != null && _currentUser!.photoUrl!.isNotEmpty
                              ? NetworkImage('https://localhost:7281${_currentUser!.photoUrl}') as ImageProvider
                              : null,
                      child: (_selectedImageBytes == null && 
                              (_currentUser?.photoUrl == null || _currentUser!.photoUrl!.isEmpty))
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                enabled: false,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Imię',
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Podaj imię';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwisko',
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Podaj nazwisko';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numer telefonu',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aboutMeController,
                decoration: const InputDecoration(
                  labelText: 'O mnie',
                  prefixIcon: Icon(Icons.info),
                ),
                maxLines: 3,
                enabled: _isEditing,
              ),
              if (_isEditing) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Zapisz zmiany'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _selectedImage = null;
                            _selectedImageBytes = null;
                          });
                          _loadUserProfile();
                        },
                        child: const Text('Anuluj'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}



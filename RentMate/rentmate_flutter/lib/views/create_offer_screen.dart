import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/property.dart';
import '../models/offer.dart';
import '../services/offer_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class CreateOfferScreen extends StatefulWidget {
  final Property property;

  const CreateOfferScreen({super.key, required this.property});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _offerService = OfferService();
  final _authService = AuthService();
  final _userService = UserService();
  bool _isLoading = false;

  final _rentAmountController = TextEditingController(text: '0');
  final _depositAmountController = TextEditingController(text: '0');
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _tenantSearchController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedTenantId;
  List<User> _searchResults = [];
  bool _isSearching = false;
  File? _selectedPdfFile;
  Uint8List? _selectedPdfBytes;

  @override
  void initState() {
    super.initState();
    // Ustaw domyślne daty
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month + 1, 1);
    _endDate = DateTime(now.year + 1, now.month + 1, 1);
    _updateDateControllers();
  }

  void _updateDateControllers() {
    if (_startDate != null) {
      _startDateController.text = _formatDate(_startDate!);
    }
    if (_endDate != null) {
      _endDateController.text = _formatDate(_endDate!);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _updateDateControllers();
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _updateDateControllers();
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final users = await _userService.searchUsersByName(query);
      setState(() {
        _searchResults = users;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas wyszukiwania użytkowników: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        if (kIsWeb) {
          final bytes = result.files.single.bytes;
          if (bytes != null) {
            setState(() {
              _selectedPdfBytes = bytes;
              _selectedPdfFile = null;
            });
          }
        } else {
          final file = File(result.files.single.path!);
          setState(() {
            _selectedPdfFile = file;
            _selectedPdfBytes = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas wybierania pliku: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proszę wybrać daty rozpoczęcia i zakończenia najmu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedTenantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proszę wybrać najemcę'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dto = CreateOfferDto(
        propertyId: widget.property.id,
        rentAmount: double.parse(_rentAmountController.text),
        depositAmount: double.parse(_depositAmountController.text),
        rentalPeriodStart: _startDate!,
        rentalPeriodEnd: _endDate!,
        tenantId: _selectedTenantId!,
      );

      final offer = await _offerService.createOffer(dto);

      // Jeśli wybrano plik PDF, wyślij go
      if (_selectedPdfFile != null || _selectedPdfBytes != null) {
        await _offerService.uploadContractPdf(offer.id, _selectedPdfFile, _selectedPdfBytes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oferta została utworzona i wysłana do najemcy!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas tworzenia oferty: ${e.toString()}'),
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
    _rentAmountController.dispose();
    _depositAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _tenantSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nowa oferta najmu'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _rentAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Kwota najmu (zł)',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Proszę podać kwotę najmu';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Kwota musi być większa od 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _depositAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Kaucja (zł)',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Proszę podać kwotę kaucji';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount < 0) {
                        return 'Kaucja nie może być ujemna';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _startDateController,
                    decoration: const InputDecoration(
                      labelText: 'Data rozpoczęcia najmu',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: _selectStartDate,
                    validator: (value) {
                      if (_startDate == null) {
                        return 'Proszę wybrać datę rozpoczęcia';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _endDateController,
                    decoration: const InputDecoration(
                      labelText: 'Data zakończenia najmu',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: _selectEndDate,
                    validator: (value) {
                      if (_endDate == null) {
                        return 'Proszę wybrać datę zakończenia';
                      }
                      if (_startDate != null && _endDate!.isBefore(_startDate!)) {
                        return 'Data zakończenia musi być późniejsza niż data rozpoczęcia';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Wyszukiwarka najemcy
                  TextFormField(
                    controller: _tenantSearchController,
                    decoration: InputDecoration(
                      labelText: 'Wyszukaj najemcę',
                      hintText: 'Wpisz imię i nazwisko',
                      border: const OutlineInputBorder(),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (value.length >= 2) {
                        _searchUsers(value);
                      } else {
                        setState(() {
                          _searchResults = [];
                          _selectedTenantId = null;
                        });
                      }
                    },
                    validator: (value) {
                      if (_selectedTenantId == null) {
                        return 'Proszę wybrać najemcę z listy';
                      }
                      return null;
                    },
                  ),
                  // Lista wyników wyszukiwania
                  if (_searchResults.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final isSelected = _selectedTenantId == int.parse(user.id);
                          return ListTile(
                            title: Text('${user.firstName} ${user.lastName}'),
                            subtitle: Text('ID: ${user.id}'),
                            selected: isSelected,
                            selectedTileColor: Colors.blue[50],
                            onTap: () {
                              setState(() {
                                _selectedTenantId = int.parse(user.id);
                                _tenantSearchController.text = '${user.firstName} ${user.lastName} (${user.id})';
                                _searchResults = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  // Wyświetl wybranego najemcę
                  if (_selectedTenantId != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Wybrany najemca: ${_tenantSearchController.text}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedTenantId = null;
                                _tenantSearchController.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Upload PDF
                  const Text(
                    'Umowa najmu (PDF) - opcjonalnie',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickPdfFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Wybierz plik PDF'),
                  ),
                  if (_selectedPdfFile != null || _selectedPdfBytes != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              kIsWeb
                                  ? 'Wybrany plik PDF'
                                  : _selectedPdfFile!.path.split('/').last,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedPdfFile = null;
                                _selectedPdfBytes = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Wróć'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child: const Text('Zapisz ofertę'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}



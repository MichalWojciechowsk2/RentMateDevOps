import 'package:flutter/material.dart';
import '../models/property.dart';
import '../models/offer.dart';
import '../services/payment_service.dart';
import '../services/offer_service.dart';

class BillsTab extends StatefulWidget {
  final Property property;

  const BillsTab({super.key, required this.property});

  @override
  State<BillsTab> createState() => _BillsTabState();
}

class _BillsTabState extends State<BillsTab> {
  final _paymentService = PaymentService();
  final _offerService = OfferService();
  final _formKey = GlobalKey<FormState>();
  
  List<Offer> _offers = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  
  // Form controllers
  int? _selectedOfferId;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  String _selectedPaymentMethod = 'Przelew';
  
  final List<String> _paymentMethods = ['Przelew', 'Gotówka', 'Karta', 'Inne'];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);
    try {
      final offers = await _offerService.getActiveAndAcceptedOffersByPropertyId(widget.property.id);
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania ofert: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOfferId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wybierz najemcę'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wybierz termin płatności'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      if (amount <= 0) {
        throw Exception('Kwota musi być większa od 0');
      }

      await _paymentService.createPayment(
        propertyId: widget.property.id,
        offerId: _selectedOfferId!,
        amount: amount,
        description: _descriptionController.text,
        dueDate: _selectedDueDate!,
        paymentMethod: _selectedPaymentMethod,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rachunek został utworzony'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset form
        _formKey.currentState!.reset();
        _amountController.clear();
        _descriptionController.clear();
        _selectedDueDate = null;
        _selectedOfferId = null;
        _selectedPaymentMethod = 'Przelew';
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas tworzenia rachunku: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _offers.isEmpty
            ? const Center(
                child: Text(
                  'Brak aktywnych ofert dla tego mieszkania',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Najemca (dropdown)
                      DropdownButtonFormField<int>(
                        value: _selectedOfferId,
                        decoration: const InputDecoration(
                          labelText: 'Najemca',
                          border: OutlineInputBorder(),
                        ),
                        items: _offers.map((offer) {
                          final tenantName = offer.tenantName.isNotEmpty
                              ? offer.tenantName
                              : 'Najemca ${offer.id}';
                          return DropdownMenuItem<int>(
                            value: offer.id,
                            child: Text(tenantName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedOfferId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Wybierz najemcę';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Kwota
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Kwota',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Podaj kwotę';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Kwota musi być większa od 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Opis
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Opis',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Podaj opis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Termin płatności
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Termin płatności',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _selectedDueDate != null
                                ? '${_selectedDueDate!.day.toString().padLeft(2, '0')}.${_selectedDueDate!.month.toString().padLeft(2, '0')}.${_selectedDueDate!.year}'
                                : 'dd.mm.rrrr',
                            style: TextStyle(
                              color: _selectedDueDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Metoda płatności
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Metoda płatności',
                          border: OutlineInputBorder(),
                        ),
                        items: _paymentMethods.map((method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value ?? 'Przelew';
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Przyciski
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      _formKey.currentState!.reset();
                                      _amountController.clear();
                                      _descriptionController.clear();
                                      _selectedDueDate = null;
                                      _selectedOfferId = null;
                                      _selectedPaymentMethod = 'Przelew';
                                      setState(() {});
                                    },
                              child: const Text('Anuluj'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Wyślij'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
  }
}



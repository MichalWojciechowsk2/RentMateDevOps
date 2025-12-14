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
  List<Map<String, dynamic>> _lastPayments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingPayments = false;
  bool _showForm = true;
  
  // Form controllers
  int? _selectedOfferId;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bankAccountController = TextEditingController();
  DateTime? _selectedDueDate;
  String _selectedPaymentMethod = 'Przelew';
  
  final List<String> _paymentMethods = ['Przelew', 'Gotówka', 'Inne'];

  @override
  void initState() {
    super.initState();
    _loadOffers();
    _loadLastPayments();
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

  Future<void> _loadLastPayments() async {
    setState(() => _isLoadingPayments = true);
    try {
      final payments = await _paymentService.getLastPaymentsForProperty(widget.property.id, count: 10);
      // Sortuj: najpierw niezapłacone, potem zapłacone
      payments.sort((a, b) {
        final aStatus = a['status']?.toString().toLowerCase() ?? '';
        final bStatus = b['status']?.toString().toLowerCase() ?? '';
        final aIsPaid = aStatus == 'completed';
        final bIsPaid = bStatus == 'completed';
        
        if (aIsPaid == bIsPaid) {
          // Jeśli oba mają ten sam status, sortuj po dacie (nowsze pierwsze)
          final aDate = a['createDateTime'] as DateTime? ?? DateTime(1970);
          final bDate = b['createDateTime'] as DateTime? ?? DateTime(1970);
          return bDate.compareTo(aDate);
        }
        // Niezapłacone przed zapłaconymi
        return aIsPaid ? 1 : -1;
      });
      
      setState(() {
        _lastPayments = payments;
        _isLoadingPayments = false;
      });
    } catch (e) {
      setState(() => _isLoadingPayments = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania rachunków: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _togglePaymentStatus(int paymentId, bool currentStatus) async {
    try {
      final newStatus = !currentStatus;
      await _paymentService.markPaymentAsPaid(paymentId, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'Rachunek oznaczony jako zapłacony' : 'Rachunek oznaczony jako niezapłacony'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadLastPayments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas aktualizacji statusu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Oczekuje';
      case 'completed':
        return 'Opłacone';
      case 'failed':
        return 'Nieudane';
      case 'cancelled':
        return 'Anulowane';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
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
    if (_selectedPaymentMethod == 'Przelew' && (_bankAccountController.text.isEmpty || _bankAccountController.text.length != 26)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Podaj prawidłowy numer konta bankowego (26 cyfr)'),
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
        bankAccountNumber: _selectedPaymentMethod == 'Przelew' ? _bankAccountController.text : null,
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
        _bankAccountController.clear();
        _selectedDueDate = null;
        _selectedOfferId = null;
        _selectedPaymentMethod = 'Przelew';
        setState(() {});
        
        // Odśwież listę rachunków
        await _loadLastPayments();
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
    _bankAccountController.dispose();
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
            : Column(
                children: [
                  // Tabs do przełączania między formularzem a listą
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _showForm = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _showForm ? Theme.of(context).primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Nowy rachunek',
                                  style: TextStyle(
                                    color: _showForm ? Colors.white : Colors.black87,
                                    fontWeight: _showForm ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _showForm = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_showForm ? Theme.of(context).primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Ostatnie rachunki (${_lastPayments.length})',
                                  style: TextStyle(
                                    color: !_showForm ? Colors.white : Colors.black87,
                                    fontWeight: !_showForm ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Zawartość
                  Expanded(
                    child: _showForm
                        ? SingleChildScrollView(
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
                                        if (value != 'Przelew') {
                                          _bankAccountController.clear();
                                        }
                                      });
                                    },
                                  ),
                                  // Numer konta bankowego (tylko dla Przelew)
                                  if (_selectedPaymentMethod == 'Przelew') ...[
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _bankAccountController,
                                      decoration: const InputDecoration(
                                        labelText: 'Numer konta bankowego',
                                        hintText: '26 cyfr',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      maxLength: 26,
                                      validator: (value) {
                                        if (_selectedPaymentMethod == 'Przelew') {
                                          if (value == null || value.isEmpty) {
                                            return 'Podaj numer konta bankowego';
                                          }
                                          if (value.length != 26) {
                                            return 'Numer konta musi mieć 26 cyfr';
                                          }
                                          if (!RegExp(r'^\d{26}$').hasMatch(value)) {
                                            return 'Numer konta może zawierać tylko cyfry';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
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
                                                  _bankAccountController.clear();
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
                          )
                        : _isLoadingPayments
                            ? const Center(child: CircularProgressIndicator())
                            : _lastPayments.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Brak rachunków',
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _loadLastPayments,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _lastPayments.length,
                                      itemBuilder: (context, index) {
                                        final payment = _lastPayments[index];
                                        final status = payment['status']?.toString() ?? 'Pending';
                                        final isPaid = status.toLowerCase() == 'completed';
                                        final dueDate = payment['dueDate'] as DateTime?;
                                        final paidAt = payment['paidAt'] as DateTime?;
                                        final tenantName = '${payment['tenantName'] ?? ''} ${payment['tenantSurname'] ?? ''}'.trim();
                                        
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            payment['description']?.toString() ?? 'Rachunek',
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          if (tenantName.isNotEmpty) ...[
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              'Najemca: $tenantName',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.grey[600],
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(status).withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        _getStatusText(status),
                                                        style: TextStyle(
                                                          color: _getStatusColor(status),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Kwota:',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                    Text(
                                                      '\$${(payment['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (dueDate != null) ...[
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Termin płatności:',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[700],
                                                        ),
                                                      ),
                                                      Text(
                                                        _formatDate(dueDate),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                if (paidAt != null) ...[
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Opłacone:',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[700],
                                                        ),
                                                      ),
                                                      Text(
                                                        _formatDate(paidAt),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.green[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                const SizedBox(height: 16),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () => _togglePaymentStatus(
                                                      payment['id'] as int,
                                                      isPaid,
                                                    ),
                                                    icon: Icon(isPaid ? Icons.close : Icons.check),
                                                    label: Text(isPaid ? 'Niezapłacone' : 'Zapłacone'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: isPaid ? Colors.red : Colors.green,
                                                      foregroundColor: Colors.white,
                                                    ),
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
              );
  }
}



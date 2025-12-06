import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/property.dart';
import '../models/offer.dart';
import '../services/offer_service.dart';
import '../services/auth_service.dart';
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
  bool _isLoading = false;

  final _rentAmountController = TextEditingController(text: '0');
  final _depositAmountController = TextEditingController(text: '0');
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _tenantIdController = TextEditingController(text: '0');

  DateTime? _startDate;
  DateTime? _endDate;

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

    setState(() => _isLoading = true);
    try {
      final dto = CreateOfferDto(
        propertyId: widget.property.id,
        rentAmount: double.parse(_rentAmountController.text),
        depositAmount: double.parse(_depositAmountController.text),
        rentalPeriodStart: _startDate!,
        rentalPeriodEnd: _endDate!,
        tenantId: int.parse(_tenantIdController.text),
      );

      await _offerService.createOffer(dto);

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
    _tenantIdController.dispose();
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
                  TextFormField(
                    controller: _tenantIdController,
                    decoration: const InputDecoration(
                      labelText: 'ID najemcy (tenantId)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Proszę podać ID najemcy';
                      }
                      final id = int.tryParse(value);
                      if (id == null || id <= 0) {
                        return 'ID najemcy musi być dodatnią liczbą';
                      }
                      return null;
                    },
                  ),
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



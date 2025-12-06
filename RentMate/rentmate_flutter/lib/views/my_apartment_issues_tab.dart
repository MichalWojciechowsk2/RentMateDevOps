import 'package:flutter/material.dart';
import '../models/property.dart';
import '../models/offer.dart';
import '../services/issue_service.dart';

class MyApartmentIssuesTab extends StatefulWidget {
  final Property property;
  final Offer acceptedOffer;

  const MyApartmentIssuesTab({super.key, required this.property, required this.acceptedOffer});

  @override
  State<MyApartmentIssuesTab> createState() => _MyApartmentIssuesTabState();
}

class _MyApartmentIssuesTabState extends State<MyApartmentIssuesTab> {
  final _formKey = GlobalKey<FormState>();
  final _issueService = IssueService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedIssueType = 'Przeciekający kran';
  String _selectedUrgency = 'Medium';
  final List<String> _issueTypes = [
    'Przeciekający kran',
    'Wilgoć',
    'Uszkodzona instalacja elektryczna',
    'Zepsuta pralka/zmywarka',
    'Problem z ogrzewaniem',
    'Zatkany odpływ',
    'Uszkodzone drzwi/okna',
    'Problem z wentylacją',
    'Inne'
  ];
  final List<String> _urgencyLevels = ['Low', 'Medium', 'High', 'Critical'];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await _issueService.createIssue(
        propertyId: widget.property.id,
        title: _selectedIssueType,
        description: _descriptionController.text.trim(),
        urgency: _selectedUrgency,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Problem został wysłany do właściciela'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset formularza
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _selectedIssueType = 'Przeciekający kran';
        _selectedUrgency = 'Medium';
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas wysyłania problemu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _getUrgencyLabel(String urgency) {
    switch (urgency) {
      case 'Low':
        return 'Niski';
      case 'Medium':
        return 'Średni';
      case 'High':
        return 'Wysoki';
      case 'Critical':
        return 'Krytyczny';
      default:
        return urgency;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Zgłoś problem',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Opisz problem, który wystąpił w mieszkaniu. Właściciel zostanie powiadomiony.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            
            // Typ problemu
            DropdownButtonFormField<String>(
              value: _selectedIssueType,
              decoration: const InputDecoration(
                labelText: 'Typ problemu',
                border: OutlineInputBorder(),
              ),
              items: _issueTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIssueType = value ?? 'Przeciekający kran';
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Opis
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Opis problemu',
                border: OutlineInputBorder(),
                hintText: 'Szczegółowo opisz problem...',
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Podaj opis problemu';
                }
                if (value.length > 2000) {
                  return 'Opis nie może być dłuższy niż 2000 znaków';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Priorytet
            DropdownButtonFormField<String>(
              value: _selectedUrgency,
              decoration: const InputDecoration(
                labelText: 'Priorytet',
                border: OutlineInputBorder(),
              ),
              items: _urgencyLevels.map((urgency) {
                return DropdownMenuItem<String>(
                  value: urgency,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(urgency),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_getUrgencyLabel(urgency)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUrgency = value ?? 'Medium';
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Przycisk wysłania
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitIssue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Wyślij problem',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


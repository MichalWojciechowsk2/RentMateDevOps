import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/property.dart';
import '../models/offer.dart';
import '../services/offer_service.dart';
import 'create_offer_screen.dart';

class RentalAgreementsTab extends StatefulWidget {
  final Property property;

  const RentalAgreementsTab({super.key, required this.property});

  @override
  State<RentalAgreementsTab> createState() => _RentalAgreementsTabState();
}

class _RentalAgreementsTabState extends State<RentalAgreementsTab> {
  final _offerService = OfferService();
  List<Offer> _offers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);
    try {
      final offers = await _offerService.getOffersByPropertyId(widget.property.id);
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

  @override
  Widget build(BuildContext context) {
    final maxOffers = widget.property.roomCount;
    // Licz tylko oferty z przypisanym najemcą (tenantId != null)
    final offersWithTenant = _offers.where((offer) => offer.tenantId != null).length;
    final availableSlots = maxOffers - offersWithTenant;

    return Column(
      children: [
        // Header z przyciskiem do tworzenia oferty
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Umowy wynajmu ($offersWithTenant/$maxOffers)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: availableSlots > 0
                    ? () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateOfferScreen(
                              property: widget.property,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadOffers();
                        }
                      }
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Nowa oferta najmu'),
              ),
            ],
          ),
        ),
        
        // Lista miejsc
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: maxOffers,
                  itemBuilder: (context, index) {
                    if (index < _offers.length) {
                      // Miejsce z ofertą
                      final offer = _offers[index];
                      return _buildOfferCard(offer);
                    } else {
                      // Wolne miejsce
                      return _buildEmptySlot();
                    }
                  },
                ),
        ),
        
        // Przycisk "Wygeneruj i wyślij umowę" na dole (jeśli są oferty)
        if (_offers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementacja generowania i wysyłania umów
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funkcja generowania umów zostanie dodana wkrótce'),
                    ),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Wygeneruj i wyślij umowę'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOfferCard(Offer offer) {
    final tenantName = offer.tenant != null
        ? '${offer.tenant!['firstName'] ?? ''} ${offer.tenant!['lastName'] ?? ''}'
        : 'Brak najemcy';
    
    String statusText;
    Color statusColor;
    switch (offer.status) {
      case OfferStatus.active:
        statusText = 'Czeka na odpowiedź';
        statusColor = Colors.blue;
        break;
      case OfferStatus.accepted:
        statusText = 'Aktywna';
        statusColor = Colors.green;
        break;
      case OfferStatus.completed:
        statusText = 'Zakończona';
        statusColor = Colors.grey;
        break;
      case OfferStatus.cancelled:
        statusText = 'Anulowana';
        statusColor = Colors.red;
        break;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Oferta #${offer.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Najemca: $tenantName',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Kwota: ${offer.rentAmount.toStringAsFixed(2)} zł/mies.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Kaucja: ${offer.depositAmount.toStringAsFixed(2)} zł',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Okres: ${_formatDate(offer.rentalPeriodStart)} - ${_formatDate(offer.rentalPeriodEnd)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            // Przyciski do pobierania PDF
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadGeneratedPdf(offer.id),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Pobierz wygenerowany PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
                if (offer.contractPdfUrl != null && offer.contractPdfUrl!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openContractPdf(offer.contractPdfUrl!),
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('Pobierz uploadowany PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openContractPdf(String pdfUrl) async {
    try {
      // Jeśli URL jest względny, dodaj bazowy URL
      String fullUrl = pdfUrl;
      if (!pdfUrl.startsWith('http')) {
        fullUrl = 'https://localhost:7281$pdfUrl';
      }
      
      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nie można otworzyć pliku PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas otwierania PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadGeneratedPdf(int offerId) async {
    try {
      setState(() => _isLoading = true);
      
      if (kIsWeb) {
        // Na web, użyj URL do pobrania PDF
        final pdfUrl = 'https://localhost:7281/api/Offer/$offerId/offerContract/pdf';
        final uri = Uri.parse(pdfUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF został otwarty w przeglądarce'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nie można otworzyć pliku PDF'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Na urządzeniu mobilnym, zapisz plik
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pobieranie PDF...'),
              backgroundColor: Colors.blue,
            ),
          );
        }

        final filePath = await _offerService.downloadAndSaveContractPdf(offerId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF został zapisany: $filePath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas pobierania PDF: $e'),
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

  Widget _buildEmptySlot() {
    return Card(
      elevation: 1,
      color: Colors.grey[100],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Wolne miejsce',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}



import 'package:flutter/material.dart' hide Notification;
import '../models/notification.dart' as models;
import '../models/offer.dart';
import '../models/property.dart';
import '../services/notification_service.dart';
import '../services/offer_service.dart';
import '../services/auth_service.dart';
import '../services/property_service.dart';
import '../services/issue_service.dart';
import '../services/payment_service.dart';
import 'edit_property_screen.dart';
import 'my_apartment_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();
  final _offerService = OfferService();
  final _authService = AuthService();
  final _propertyService = PropertyService();
  final _issueService = IssueService();
  final _paymentService = PaymentService();
  List<models.Notification> _notifications = [];
  List<Offer> _userOffers = [];
  Map<int, Property> _propertiesCache = {}; // Cache właściwości dla ofert
  Map<int, int> _issuePropertyMap = {}; // Mapowanie Issue ID -> Property ID
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _notificationService.getNotifications();
      // Pobierz oferty użytkownika, aby móc znaleźć offerId dla powiadomień
      final user = await _authService.getCurrentUser();
      if (user != null) {
        try {
          // user.id jest String, konwertujemy na int
          final userId = int.tryParse(user.id) ?? 0;
          if (userId > 0) {
            final offers = await _offerService.getOffersByUserId(userId);
            setState(() {
              _userOffers = offers;
            });
            
            // Pobierz szczegóły mieszkania dla każdej oferty
            final Map<int, Property> propertiesMap = {};
            for (var offer in offers) {
              if (!propertiesMap.containsKey(offer.propertyId)) {
                try {
                  final property = await _propertyService.getPropertyDetails(offer.propertyId);
                  propertiesMap[offer.propertyId] = property;
                } catch (e) {
                  print('Failed to load property ${offer.propertyId}: $e');
                }
              }
            }
            setState(() {
              _propertiesCache = propertiesMap;
            });
          }
        } catch (e) {
          // Może nie być ofert - to OK
          print('No offers found: $e');
        }
        
        // Dla powiadomień Issue, pobierz Issues dla właściciela i zmapuj propertyId
        try {
          final userId = int.tryParse(user.id) ?? 0;
          if (userId > 0 && user.role == 'Owner') {
            // Pobierz wszystkie Issues dla wszystkich properties właściciela
            final ownerProperties = await _propertyService.getMyProperties();
            final Map<int, int> issuePropertyMap = {};
            
            for (var property in ownerProperties) {
              try {
                final issues = await _issueService.getIssuesByPropertyId(property.id);
                for (var issue in issues) {
                  // Mapuj Issue ID do Property ID
                  final issueId = issue['id'] as int;
                  issuePropertyMap[issueId] = property.id;
                }
              } catch (e) {
                print('Failed to load issues for property ${property.id}: $e');
              }
            }
            
            setState(() {
              _issuePropertyMap = issuePropertyMap;
            });
          }
        } catch (e) {
          print('Failed to load issues: $e');
        }
      }
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania powiadomień: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleOfferAction(models.Notification notification, bool accept) async {
    try {
      setState(() => _isLoading = true);
      
      // Znajdź aktywną ofertę dla tego powiadomienia
      // Dla powiadomień SendOffer, receiverId to ID zalogowanego użytkownika (najemca)
      // Szukamy aktywnej oferty gdzie tenantId = receiverId (ID zalogowanego najemcy)
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('Użytkownik nie jest zalogowany');
      }

      // Konwertuj user.id (String) na int
      final userId = int.tryParse(user.id) ?? 0;
      if (userId == 0) {
        throw Exception('Nieprawidłowe ID użytkownika');
      }

      Offer? matchingOffer;
      if (notification.type == models.NotificationType.sendOffer) {
        try {
          matchingOffer = _userOffers.firstWhere(
            (offer) => 
              offer.status == OfferStatus.active &&
              offer.tenantId == userId &&
              offer.createdAt.difference(notification.createdAt).abs().inDays <= 1,
          );
        } catch (e) {
          // Jeśli nie znaleziono dokładnej oferty, spróbuj znaleźć jakąkolwiek aktywną ofertę dla użytkownika
          matchingOffer = _userOffers.firstWhere(
            (offer) => 
              offer.status == OfferStatus.active &&
              offer.tenantId == userId,
            orElse: () => throw Exception('Nie znaleziono pasującej oferty'),
          );
        }
      }

      if (matchingOffer == null) {
        throw Exception('Nie znaleziono pasującej oferty');
      }

      // Zaakceptuj lub odrzuć ofertę
      if (accept) {
        await _offerService.acceptOffer(matchingOffer.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oferta została zaakceptowana!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _offerService.declineOffer(matchingOffer.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oferta została odrzucona.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Oznacz jako przeczytane
      await _notificationService.markAsRead(notification.id);
      
      // Odśwież dane
      _loadData();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Powiadomienia'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    'Brak powiadomień',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationCard(models.Notification notification) {
    final isOfferNotification = notification.type == models.NotificationType.sendOffer;
    final isIssueNotification = notification.type == models.NotificationType.createIssue;
    final isPaymentNotification = notification.type == models.NotificationType.createPayment || 
                                   notification.type == models.NotificationType.paymentDue;
    
    // Znajdź pasującą ofertę dla tego powiadomienia
    // Dla powiadomień SendOffer, receiverId to ID najemcy (zalogowanego użytkownika)
    Offer? matchingOffer;
    Property? property;
    
    if (isOfferNotification && _userOffers.isNotEmpty) {
      // Znajdź ofertę gdzie tenantId pasuje do receiverId z powiadomienia
      // i status jest Active oraz data utworzenia jest podobna
      try {
        matchingOffer = _userOffers.firstWhere(
          (offer) =>
            offer.status == OfferStatus.active &&
            offer.tenantId == notification.receiverId &&
            offer.createdAt.difference(notification.createdAt).abs().inDays <= 1,
        );
      } catch (e) {
        // Jeśli nie znaleziono dokładnie pasującej, spróbuj znaleźć aktywną ofertę dla tego najemcy
        try {
          matchingOffer = _userOffers.firstWhere(
            (offer) =>
              offer.status == OfferStatus.active &&
              offer.tenantId == notification.receiverId,
          );
        } catch (e2) {
          // Brak pasującej oferty - może być inne powiadomienie
        }
      }
      
      // Pobierz szczegóły mieszkania jeśli znaleziono ofertę
      if (matchingOffer != null) {
        property = _propertiesCache[matchingOffer!.propertyId];
      }
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead 
          ? Colors.white 
          : (isIssueNotification ? Colors.orange[50] : Colors.blue[50]),
      child: InkWell(
        onTap: () async {
          // Oznacz jako przeczytane
          await _notificationService.markAsRead(notification.id);
          
          if (isIssueNotification) {
            // Nawigacja dla powiadomień Issue
            int? propertyId;
            
            final user = await _authService.getCurrentUser();
            if (user != null && user.role == 'Owner') {
              try {
                final ownerProperties = await _propertyService.getMyProperties();
                
                for (var property in ownerProperties) {
                  try {
                    final issues = await _issueService.getIssuesByPropertyId(property.id);
                    for (var issue in issues) {
                      final issueTenantId = issue['tenantId'] as int;
                      final issueCreatedAt = issue['createdAt'] as DateTime?;
                      
                      if (issueTenantId == notification.senderId &&
                          issueCreatedAt != null &&
                          issueCreatedAt.difference(notification.createdAt).abs().inDays <= 1) {
                        propertyId = property.id;
                        break;
                      }
                    }
                    if (propertyId != null) break;
                  } catch (e) {
                    print('Failed to check issues for property ${property.id}: $e');
                  }
                }
                
                if (propertyId != null) {
                  final property = await _propertyService.getPropertyDetails(propertyId);
                  if (mounted) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPropertyScreen(initialTabIndex: 3), // 3 = zakładka "Problemy"
                        settings: RouteSettings(arguments: property),
                      ),
                    );
                    _loadData();
                  }
                } else {
                  _loadData();
                }
              } catch (e) {
                print('Error navigating to property: $e');
                _loadData();
              }
            } else {
              _loadData();
            }
          } else if (isPaymentNotification) {
            // Nawigacja dla powiadomień o płatnościach
            final user = await _authService.getCurrentUser();
            if (user == null) {
              _loadData();
              return;
            }
            
            try {
              if (user.role == 'Tenant') {
                // Dla najemcy - przejdź do MyApartmentScreen z zakładką Rachunki
                final userId = int.tryParse(user.id) ?? 0;
                if (userId > 0) {
                  final acceptedOffer = await _offerService.getAcceptedOffer(userId);
                  if (acceptedOffer != null && mounted) {
                    // Przejdź do MyApartmentScreen z zakładką Rachunki (index 1)
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyApartmentScreen(
                          acceptedOffer: acceptedOffer,
                          initialTabIndex: 1, // 1 = zakładka "Rachunki"
                        ),
                      ),
                    );
                    _loadData();
                  } else {
                    _loadData();
                  }
                } else {
                  _loadData();
                }
              } else if (user.role == 'Owner') {
                // Dla właściciela - znajdź propertyId poprzez oferty
                // Dla powiadomienia createPayment, receiverId to tenantId
                // Znajdź ofertę dla tego tenantId i weź propertyId
                int? propertyId;
                
                try {
                  // Pobierz wszystkie properties właściciela
                  final ownerProperties = await _propertyService.getMyProperties();
                  
                  // Dla każdego property, sprawdź aktywne/zaakceptowane oferty
                  for (var property in ownerProperties) {
                    try {
                      final offers = await _offerService.getActiveAndAcceptedOffersByPropertyId(property.id);
                      // Znajdź ofertę, która pasuje do tenantId z powiadomienia (receiverId)
                      try {
                        final matchingOffer = offers.firstWhere(
                          (offer) => offer.tenantId == notification.receiverId,
                        );
                        // Jeśli znaleziono pasującą ofertę, użyj tego propertyId
                        propertyId = property.id;
                        break;
                      } catch (e) {
                        // Brak pasującej oferty dla tego property - kontynuuj
                        continue;
                      }
                    } catch (e) {
                      // Błąd podczas pobierania ofert - kontynuuj
                      continue;
                    }
                  }
                  
                  // Jeśli znaleziono propertyId, przejdź do EditPropertyScreen z zakładką "Rachunki"
                  if (propertyId != null) {
                    final property = await _propertyService.getPropertyDetails(propertyId);
                    if (mounted) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPropertyScreen(initialTabIndex: 2), // 2 = zakładka "Rachunki"
                          settings: RouteSettings(arguments: property),
                        ),
                      );
                      _loadData();
                    }
                  } else {
                    _loadData();
                  }
                } catch (e) {
                  print('Error navigating to property payments: $e');
                  _loadData();
                }
              } else {
                _loadData();
              }
            } catch (e) {
              print('Error handling payment notification: $e');
              _loadData();
            }
          } else {
            // Dla innych typów powiadomień, tylko odśwież
            _loadData();
          }
        },
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
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: notification.isRead ? Colors.black : Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: notification.isRead ? Colors.grey[700] : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            
            // Wyświetl szczegóły dla powiadomień Issue
            if (isIssueNotification) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.report_problem, color: Colors.orange[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Najemca zgłosił problem w mieszkaniu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kliknij, aby zobaczyć szczegóły i zarządzać problemami',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange[700]),
                  ],
                ),
              ),
            ],
            
            // Wyświetl szczegóły oferty i mieszkania dla powiadomień SendOffer
            if (isOfferNotification && matchingOffer != null && property != null) ...[
              const Divider(height: 24, thickness: 1),
              Text(
                'Szczegóły oferty:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              
              // Informacje o mieszkaniu - klikalne, aby zobaczyć szczegóły
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/property-details',
                    arguments: property!.id,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.home, size: 20, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    property!.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.blue[700],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${property!.city}, ${property!.district}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${property!.roomCount} pokoi • ${property!.area} m²',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Warunki umowy
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warunki umowy:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildOfferDetailRow('Czynsz miesięczny', '${matchingOffer!.rentAmount.toStringAsFixed(2)} zł'),
                    const SizedBox(height: 4),
                    _buildOfferDetailRow('Kaucja', '${matchingOffer!.depositAmount.toStringAsFixed(2)} zł'),
                    const SizedBox(height: 4),
                    _buildOfferDetailRow(
                      'Okres najmu',
                      '${_formatDateShort(matchingOffer!.rentalPeriodStart)} - ${_formatDateShort(matchingOffer!.rentalPeriodEnd)}',
                    ),
                  ],
                ),
              ),
            ],
            
            // Akcje dla powiadomień o ofertach
            if (isOfferNotification && !notification.isRead) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _handleOfferAction(notification, false),
                    child: const Text('Odrzuć', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleOfferAction(notification, true),
                    child: const Text('Zaakceptuj'),
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
  
  Widget _buildOfferDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Przed ${difference.inMinutes} minutami';
      }
      return 'Przed ${difference.inHours} godzinami';
    } else if (difference.inDays == 1) {
      return 'Wczoraj';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dni temu';
    } else {
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }
  }
}



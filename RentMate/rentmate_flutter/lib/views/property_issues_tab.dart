import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/issue_service.dart';

class PropertyIssuesTab extends StatefulWidget {
  final Property property;

  const PropertyIssuesTab({super.key, required this.property});

  @override
  State<PropertyIssuesTab> createState() => _PropertyIssuesTabState();
}

class _PropertyIssuesTabState extends State<PropertyIssuesTab> {
  final _issueService = IssueService();
  List<Map<String, dynamic>> _issues = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  Future<void> _loadIssues() async {
    setState(() => _isLoading = true);
    try {
      final issues = await _issueService.getIssuesByPropertyId(widget.property.id);
      setState(() {
        _issues = issues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania problemów: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return 'Nowy';
      case 'inprogress':
        return 'W trakcie';
      case 'resolved':
        return 'Rozwiązany';
      case 'closed':
        return 'Zamknięty';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'inprogress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getUrgencyLabel(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'low':
      case '0':
        return 'Niski';
      case 'medium':
      case '1':
        return 'Średni';
      case 'high':
      case '2':
        return 'Wysoki';
      case 'critical':
      case '3':
        return 'Krytyczny';
      default:
        return urgency;
    }
  }

  String _normalizeUrgency(String urgency) {
    // Konwertuj liczbę lub różne formaty na string enum
    final urgencyLower = urgency.toLowerCase();
    if (urgency == '0' || urgencyLower == 'low') return 'low';
    if (urgency == '1' || urgencyLower == 'medium') return 'medium';
    if (urgency == '2' || urgencyLower == 'high') return 'high';
    if (urgency == '3' || urgencyLower == 'critical') return 'critical';
    return urgencyLower;
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'low':
      case '0':
        return Colors.green;
      case 'medium':
      case '1':
        return Colors.orange;
      case 'high':
      case '2':
        return Colors.red;
      case 'critical':
      case '3':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyBackgroundColor(String urgency, String status) {
    // Jeśli problem jest rozwiązany, użyj szarego koloru
    if (status.toLowerCase() == 'resolved' || status.toLowerCase() == 'closed') {
      return Colors.grey.shade200;
    }
    
    switch (urgency.toLowerCase()) {
      case 'low':
      case '0':
        return Colors.green.shade50;
      case 'medium':
      case '1':
        return Colors.orange.shade50;
      case 'high':
      case '2':
        return Colors.red.shade50;
      case 'critical':
      case '3':
        return Colors.deepPurple.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getUrgencyBorderColor(String urgency, String status) {
    // Jeśli problem jest rozwiązany, użyj szarego koloru
    if (status.toLowerCase() == 'resolved' || status.toLowerCase() == 'closed') {
      return Colors.grey.shade400;
    }
    
    switch (urgency.toLowerCase()) {
      case 'low':
      case '0':
        return Colors.green.shade300;
      case 'medium':
      case '1':
        return Colors.orange.shade300;
      case 'high':
      case '2':
        return Colors.red.shade300;
      case 'critical':
      case '3':
        return Colors.deepPurple.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getUrgencyTextColor(String urgency, String status) {
    // Jeśli problem jest rozwiązany, użyj szarego koloru
    if (status.toLowerCase() == 'resolved' || status.toLowerCase() == 'closed') {
      return Colors.grey.shade700;
    }
    
    return _getUrgencyColor(urgency);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateIssueStatus(int issueId, String newStatus) async {
    try {
      // Optymistyczna aktualizacja - zaktualizuj lokalnie od razu
      setState(() {
        final issueIndex = _issues.indexWhere((issue) => issue['id'] == issueId);
        if (issueIndex != -1) {
          // Zaktualizuj status w lokalnej liście
          final updatedIssue = Map<String, dynamic>.from(_issues[issueIndex]);
          updatedIssue['status'] = newStatus;
          _issues[issueIndex] = updatedIssue;
        }
      });
      
      // Wyślij aktualizację do API
      await _issueService.updateIssueStatus(issueId, newStatus);
      
      // Odśwież dane z serwera
      await _loadIssues();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status problemu został zaktualizowany'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // W przypadku błędu, odśwież dane z serwera aby przywrócić poprawny stan
      await _loadIssues();
      
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadIssues,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _issues.isEmpty
              ? const Center(
                  child: Text(
                    'Brak zgłoszonych problemów',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _issues.length,
                  itemBuilder: (context, index) {
                    final issue = _issues[index];
                    final statusRaw = issue['status'];
                    // Status może być liczbą (0=New, 1=InProgress, 2=Resolved, 3=Closed) lub stringiem
                    String status;
                    if (statusRaw is int) {
                      switch (statusRaw) {
                        case 0:
                          status = 'New';
                          break;
                        case 1:
                          status = 'InProgress';
                          break;
                        case 2:
                          status = 'Resolved';
                          break;
                        case 3:
                          status = 'Closed';
                          break;
                        default:
                          status = 'New';
                      }
                    } else {
                      status = statusRaw?.toString() ?? 'New';
                    }
                    final urgencyRaw = issue['urgency']?.toString() ?? 'Medium';
                    final urgency = _normalizeUrgency(urgencyRaw);
                    final createdAt = issue['createdAt'] as DateTime?;

                    final isResolved = status.toLowerCase() == 'resolved' || status.toLowerCase() == 'closed';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: _getUrgencyBackgroundColor(urgency, status),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _getUrgencyBorderColor(urgency, status),
                          width: 2,
                        ),
                      ),
                      elevation: isResolved ? 1 : (urgency == 'critical' || urgency == 'high' ? 4 : 2),
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              issue['title']?.toString() ?? 'Problem',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: _getUrgencyTextColor(urgency, status),
                                                decoration: isResolved ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if (!isResolved)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getUrgencyColor(urgency),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                urgency == 'critical' || urgency == 'high'
                                                    ? Icons.warning
                                                    : Icons.info_outline,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Ważność: ${_getUrgencyLabel(urgency)}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade600,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Zrobione',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: isResolved,
                                      onChanged: (bool? value) async {
                                        if (value == true) {
                                          await _updateIssueStatus(issue['id'] as int, 'Resolved');
                                        } else {
                                          await _updateIssueStatus(issue['id'] as int, 'New');
                                        }
                                      },
                                      activeColor: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
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
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              issue['description']?.toString() ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: isResolved ? Colors.grey[600] : Colors.grey[700],
                                decoration: isResolved ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (createdAt != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Zgłoszono: ${_formatDate(createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            if (status.toLowerCase() == 'new' || status.toLowerCase() == 'inprogress') ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  if (status.toLowerCase() == 'new')
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _updateIssueStatus(
                                          issue['id'] as int,
                                          'InProgress',
                                        ),
                                        child: const Text('Rozpocznij'),
                                      ),
                                    ),
                                  if (status.toLowerCase() == 'new' && status.toLowerCase() == 'inprogress')
                                    const SizedBox(width: 8),
                                  if (status.toLowerCase() == 'inprogress')
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _updateIssueStatus(
                                          issue['id'] as int,
                                          'Resolved',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        child: const Text('Rozwiązane'),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}



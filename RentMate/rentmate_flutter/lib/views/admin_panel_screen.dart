import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/report_service.dart';
import '../models/admin_user.dart';
import '../models/admin_review.dart';
import '../models/report.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  final _adminService = AdminService();
  final _reportService = ReportService();
  late TabController _tabController;

  List<AdminUser> _users = [];
  List<AdminReview> _reviews = [];
  List<Report> _reports = [];
  bool _isLoadingUsers = false;
  bool _isLoadingReviews = false;
  bool _isLoadingReports = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final users = await _adminService.getAllUsers();
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() => _isLoadingUsers = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania użytkowników: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final reviews = await _adminService.getAllReviews();
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() => _isLoadingReviews = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania ocen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadReports() async {
    setState(() => _isLoadingReports = true);
    try {
      final reports = await _reportService.getUnresolvedReports();
      setState(() {
        _reports = reports;
        _isLoadingReports = false;
      });
    } catch (e) {
      setState(() => _isLoadingReports = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas ładowania zgłoszeń: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resolveReport(int reportId) async {
    try {
      await _reportService.resolveReport(reportId);
      await _loadReports();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zgłoszenie zostało oznaczone jako rozwiązane'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _banUser(int userId) async {
    try {
      await _adminService.banUser(userId);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Użytkownik został zbanowany'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unbanUser(int userId) async {
    try {
      await _adminService.unbanUser(userId);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Użytkownik został odbanowany'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń użytkownika'),
        content: const Text('Czy na pewno chcesz usunąć to konto? Ta operacja jest nieodwracalna.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _adminService.deleteUser(userId);
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konto zostało usunięte'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Błąd: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń ocenę'),
        content: const Text('Czy na pewno chcesz usunąć tę ocenę?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _adminService.deleteReview(reviewId);
        await _loadReviews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ocena została usunięta'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Błąd: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel administratora'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 1 && _reviews.isEmpty) {
              _loadReviews();
            } else if (index == 2 && _reports.isEmpty) {
              _loadReports();
            }
          },
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Użytkownicy'),
            Tab(icon: Icon(Icons.star), text: 'Oceny'),
            Tab(icon: Icon(Icons.flag), text: 'Zgłoszenia'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildReviewsTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: _users.isEmpty
          ? const Center(child: Text('Brak użytkowników'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text('${user.firstName} ${user.lastName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${user.email}'),
                        Text('Rola: ${user.role}'),
                        if (user.isBanned)
                          const Text(
                            'ZABANOWANY',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user.role != 'Administrator') ...[
                          if (user.isBanned)
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _unbanUser(user.id),
                              tooltip: 'Odbanuj',
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.block, color: Colors.orange),
                              onPressed: () => _banUser(user.id),
                              tooltip: 'Zbanuj',
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user.id),
                            tooltip: 'Usuń konto',
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

  Widget _buildReviewsTab() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      child: _reviews.isEmpty
          ? const Center(child: Text('Brak ocen'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Row(
                      children: [
                        if (review.rating != null)
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < (review.rating!.round()) ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        Expanded(
                          child: Text(
                            review.propertyId != null
                                ? 'Ocena mieszkania'
                                : 'Ocena użytkownika',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (review.authorName != null)
                          Text('Autor: ${review.authorName}'),
                        if (review.propertyAddress != null)
                          Text('Mieszkanie: ${review.propertyAddress}'),
                        if (review.reviewedUserName != null)
                          Text('Oceniany: ${review.reviewedUserName}'),
                        if (review.comment.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(review.comment),
                          ),
                        Text(
                          'Data: ${_formatDate(review.createdAt)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReview(review.id),
                      tooltip: 'Usuń ocenę',
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildReportsTab() {
    if (_isLoadingReports) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: _reports.isEmpty
          ? const Center(child: Text('Brak zgłoszeń'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: report.isResolved ? Colors.grey[200] : Colors.white,
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zgłoszony: ${report.reportedUserName ?? 'Nieznany'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Zgłaszający: ${report.reporterName ?? 'Nieznany'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Powód: ${report.reason}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Data: ${_formatDate(report.createdAt)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        if (report.isResolved && report.resolvedByAdminName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Rozwiązane przez: ${report.resolvedByAdminName}',
                            style: TextStyle(fontSize: 12, color: Colors.green[700]),
                          ),
                        ],
                      ],
                    ),
                    trailing: !report.isResolved
                        ? IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _resolveReport(report.id),
                            tooltip: 'Oznacz jako rozwiązane',
                          )
                        : const Icon(Icons.check_circle, color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}


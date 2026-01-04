class Report {
  final int id;
  final int reportedUserId;
  final int reporterId;
  final String reason;
  final DateTime createdAt;
  final bool isResolved;
  final DateTime? resolvedAt;
  final int? resolvedByAdminId;
  final String? reportedUserName;
  final String? reporterName;
  final String? resolvedByAdminName;

  Report({
    required this.id,
    required this.reportedUserId,
    required this.reporterId,
    required this.reason,
    required this.createdAt,
    required this.isResolved,
    this.resolvedAt,
    this.resolvedByAdminId,
    this.reportedUserName,
    this.reporterName,
    this.resolvedByAdminName,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      reportedUserId: json['reportedUserId'] is int ? json['reportedUserId'] : int.tryParse(json['reportedUserId']?.toString() ?? '') ?? 0,
      reporterId: json['reporterId'] is int ? json['reporterId'] : int.tryParse(json['reporterId']?.toString() ?? '') ?? 0,
      reason: json['reason']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      isResolved: json['isResolved'] == true,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'].toString())
          : null,
      resolvedByAdminId: json['resolvedByAdminId'],
      reportedUserName: json['reportedUserName']?.toString(),
      reporterName: json['reporterName']?.toString(),
      resolvedByAdminName: json['resolvedByAdminName']?.toString(),
    );
  }
}


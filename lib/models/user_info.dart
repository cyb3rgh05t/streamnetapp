class UserInfo {
  final String username;
  final String password;
  final String status;
  final String? expDate;
  final bool isTrial;
  final int? activeCons;
  final int? maxConnections;
  final String? createdAt;
  final List<String>? allowedOutputFormats;

  UserInfo({
    required this.username,
    required this.password,
    required this.status,
    this.expDate,
    this.isTrial = false,
    this.activeCons,
    this.maxConnections,
    this.createdAt,
    this.allowedOutputFormats,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      status: json['status'] ?? '',
      expDate: json['exp_date']?.toString(),
      isTrial: json['is_trial'] == '1' || json['is_trial'] == true,
      activeCons: int.tryParse(json['active_cons']?.toString() ?? '0'),
      maxConnections: int.tryParse(json['max_connections']?.toString() ?? '1'),
      createdAt: json['created_at']?.toString(),
      allowedOutputFormats: json['allowed_output_formats'] != null
          ? List<String>.from(json['allowed_output_formats'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'status': status,
      'exp_date': expDate,
      'is_trial': isTrial ? '1' : '0',
      'active_cons': activeCons.toString(),
      'max_connections': maxConnections.toString(),
      'created_at': createdAt,
      'allowed_output_formats': allowedOutputFormats,
    };
  }

  /// Check if subscription is active
  bool get isActive => status == 'Active';

  /// Get remaining days
  int? get remainingDays {
    if (expDate == null) return null;

    try {
      final expTimestamp = int.tryParse(expDate!);
      if (expTimestamp != null) {
        final expDateTime = DateTime.fromMillisecondsSinceEpoch(
          expTimestamp * 1000,
        );
        return expDateTime.difference(DateTime.now()).inDays;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Get formatted expiration date
  String? get formattedExpDate {
    if (expDate == null) return null;

    try {
      final expTimestamp = int.tryParse(expDate!);
      if (expTimestamp != null) {
        final expDateTime = DateTime.fromMillisecondsSinceEpoch(
          expTimestamp * 1000,
        );
        return '${expDateTime.day}.${expDateTime.month}.${expDateTime.year}';
      }
    } catch (e) {
      return expDate;
    }
    return expDate;
  }
}

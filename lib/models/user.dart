class User {
  final int? id;
  final String employeeId;
  final String? username;
  final String? email;
  final String firstName;
  final String lastName;
  final String role;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final DateTime? dateJoined;
  final DateTime? lastLogin;

  User({
    this.id,
    required this.employeeId,
    this.username,
    this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.isActive = true,
    this.isStaff = false,
    this.isSuperuser = false,
    this.dateJoined,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      employeeId: json['employee_id'] ?? json['employeeId'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      role: json['role'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      isStaff: json['is_staff'] ?? json['isStaff'] ?? false,
      isSuperuser: json['is_superuser'] ?? json['isSuperuser'] ?? false,
      dateJoined: json['date_joined'] != null 
          ? DateTime.parse(json['date_joined']) 
          : null,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'date_joined': dateJoined?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? employeeId,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    DateTime? dateJoined,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  String get fullName => '$firstName $lastName';
  String get displayName => employeeId;

  bool get isAdmin => role == 'ADMIN' || role == 'SUPERADMIN';
  bool get isSuperAdmin => role == 'SUPERADMIN';
  bool get isFieldWorker => role == 'FIELD_WORKER';

  @override
  String toString() {
    return 'User(id: $id, employeeId: $employeeId, name: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.employeeId == employeeId;
  }

  @override
  int get hashCode => employeeId.hashCode;
} 
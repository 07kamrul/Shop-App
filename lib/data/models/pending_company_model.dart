import 'package:equatable/equatable.dart';

class PendingCompany extends Equatable {
  final String id;
  final String name;
  final String description;
  final String phone;
  final String email;
  final String address;
  final int status;
  final String statusDisplay;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String? ownerPhone;
  final DateTime createdAt;

  const PendingCompany({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    required this.email,
    required this.address,
    required this.status,
    required this.statusDisplay,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    this.ownerPhone,
    required this.createdAt,
  });

  factory PendingCompany.fromJson(Map<String, dynamic> json) {
    return PendingCompany(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? 0,
      statusDisplay: json['status_display'] ?? json['statusDisplay'] ?? '',
      ownerId: json['owner_id'] ?? json['ownerId'] ?? '',
      ownerName: json['owner_name'] ?? json['ownerName'] ?? '',
      ownerEmail: json['owner_email'] ?? json['ownerEmail'] ?? '',
      ownerPhone: json['owner_phone'] ?? json['ownerPhone'],
      createdAt: DateTime.parse(
        json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        phone,
        email,
        address,
        status,
        statusDisplay,
        ownerId,
        ownerName,
        ownerEmail,
        ownerPhone,
        createdAt,
      ];
}

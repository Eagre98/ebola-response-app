import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertCategory { suspectedCase, confirmedCase, outbreak }

enum AlertStatus { open, assigned, inProgress, closed }

class AlertLocation {
  final double latitude;
  final double longitude;
  final String address;

  AlertLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory AlertLocation.fromMap(Map<String, dynamic> map) {
    return AlertLocation(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'] ?? '',
    );
  }
}

class AlertModel {
  final String id;
  final String title;
  final String description;
  final AlertCategory category;
  final AlertStatus status;
  final AlertLocation location;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final String createdBy; // UID of creator
  final String? assignedTo; // UID of assigned medical team member
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? closedAt;
  final String? closedBy; // UID of person who closed
  final String? notes; // Additional notes for closure

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.location,
    required this.imageUrls,
    required this.videoUrls,
    required this.createdBy,
    this.assignedTo,
    required this.createdAt,
    this.assignedAt,
    this.closedAt,
    this.closedBy,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'status': status.toString().split('.').last,
      'location': location.toMap(),
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'createdAt': Timestamp.fromDate(createdAt),
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'closedBy': closedBy,
      'notes': notes,
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map, String id) {
    return AlertModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: AlertCategory.values.firstWhere(
        (cat) => cat.toString().split('.').last == map['category'],
        orElse: () => AlertCategory.suspectedCase,
      ),
      status: AlertStatus.values.firstWhere(
        (stat) => stat.toString().split('.').last == map['status'],
        orElse: () => AlertStatus.open,
      ),
      location: AlertLocation.fromMap(map['location'] ?? {}),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrls: List<String>.from(map['videoUrls'] ?? []),
      createdBy: map['createdBy'] ?? '',
      assignedTo: map['assignedTo'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      assignedAt: map['assignedAt'] != null
          ? (map['assignedAt'] as Timestamp).toDate()
          : null,
      closedAt: map['closedAt'] != null
          ? (map['closedAt'] as Timestamp).toDate()
          : null,
      closedBy: map['closedBy'],
      notes: map['notes'],
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case AlertCategory.suspectedCase:
        return 'Suspected Case';
      case AlertCategory.confirmedCase:
        return 'Confirmed Case';
      case AlertCategory.outbreak:
        return 'Outbreak';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case AlertStatus.open:
        return 'Open';
      case AlertStatus.assigned:
        return 'Assigned';
      case AlertStatus.inProgress:
        return 'In Progress';
      case AlertStatus.closed:
        return 'Closed';
    }
  }

  AlertModel copyWith({
    String? id,
    String? title,
    String? description,
    AlertCategory? category,
    AlertStatus? status,
    AlertLocation? location,
    List<String>? imageUrls,
    List<String>? videoUrls,
    String? createdBy,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? assignedAt,
    DateTime? closedAt,
    String? closedBy,
    String? notes,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      location: location ?? this.location,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      closedAt: closedAt ?? this.closedAt,
      closedBy: closedBy ?? this.closedBy,
      notes: notes ?? this.notes,
    );
  }
}

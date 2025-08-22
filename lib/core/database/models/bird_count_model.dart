class BirdCountModel {
  final String id;
  final String siteId;
  final String birdName;
  final int count;
  final String? observerName;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BirdCountModel({
    required this.id,
    required this.siteId,
    required this.birdName,
    required this.count,
    this.observerName,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'siteId': siteId,
      'birdName': birdName,
      'count': count,
      'observerName': observerName,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BirdCountModel.fromMap(Map<String, dynamic> map) {
    return BirdCountModel(
      id: map['id'],
      siteId: map['siteId'],
      birdName: map['birdName'],
      count: map['count'],
      observerName: map['observerName'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  BirdCountModel copyWith({
    String? id,
    String? siteId,
    String? birdName,
    int? count,
    String? observerName,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BirdCountModel(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      birdName: birdName ?? this.birdName,
      count: count ?? this.count,
      observerName: observerName ?? this.observerName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
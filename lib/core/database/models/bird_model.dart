class BirdModel {
  final String id;
  final String name;
  final String scientificName;
  final String family;
  final String status;
  final String? imagePath;
  final String? imageUrl;
  final String? description;
  final String? habitat;
  final String? diet;
  final DateTime createdAt;
  final DateTime updatedAt;

  BirdModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.family,
    required this.status,
    this.imagePath,
    this.imageUrl,
    this.description,
    this.habitat,
    this.diet,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'family': family,
      'status': status,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'description': description,
      'habitat': habitat,
      'diet': diet,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BirdModel.fromMap(Map<String, dynamic> map) {
    return BirdModel(
      id: map['id'],
      name: map['name'],
      scientificName: map['scientificName'],
      family: map['family'],
      status: map['status'],
      imagePath: map['imagePath'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      habitat: map['habitat'],
      diet: map['diet'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  BirdModel copyWith({
    String? id,
    String? name,
    String? scientificName,
    String? family,
    String? status,
    String? imagePath,
    String? imageUrl,
    String? description,
    String? habitat,
    String? diet,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BirdModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      family: family ?? this.family,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      habitat: habitat ?? this.habitat,
      diet: diet ?? this.diet,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
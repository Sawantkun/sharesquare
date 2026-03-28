class HouseholdModel {
  final String id;
  final String name;
  final String address;
  final String joinCode;
  final List<String> memberIds;
  final String adminId;
  final String? imageUrl;
  final DateTime createdAt;

  const HouseholdModel({
    required this.id,
    required this.name,
    required this.address,
    required this.joinCode,
    required this.memberIds,
    required this.adminId,
    this.imageUrl,
    required this.createdAt,
  });

  int get memberCount => memberIds.length;

  HouseholdModel copyWith({
    String? id,
    String? name,
    String? address,
    String? joinCode,
    List<String>? memberIds,
    String? adminId,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return HouseholdModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      joinCode: joinCode ?? this.joinCode,
      memberIds: memberIds ?? this.memberIds,
      adminId: adminId ?? this.adminId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'joinCode': joinCode,
    'memberIds': memberIds,
    'adminId': adminId,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HouseholdModel.fromJson(Map<String, dynamic> json) => HouseholdModel(
    id: (json['id'] as String?) ?? '',
    name: (json['name'] as String?) ?? '',
    address: (json['address'] as String?) ?? '',
    joinCode: (json['joinCode'] as String?) ?? '',
    memberIds: List<String>.from(json['memberIds'] ?? []),
    adminId: (json['adminId'] as String?) ?? '',
    imageUrl: json['imageUrl'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );
}

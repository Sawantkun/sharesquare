import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final Color color;
  final String? householdId;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.color,
    this.householdId,
    required this.createdAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    Color? color,
    String? householdId,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      color: color ?? this.color,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'color': color.toARGB32(),
    'householdId': householdId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    avatarUrl: json['avatarUrl'],
    color: Color(json['color'] ?? AppColors.primary.toARGB32()),
    householdId: json['householdId'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

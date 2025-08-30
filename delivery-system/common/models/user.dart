import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

enum UserRole { admin, leader, driver, restaurant }

enum UserStatus { active, inactive, banned }

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final UserStatus status;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Driver specific fields
  final String? vehicleType;
  final String? vehicleNumber;
  final String? driverLicense;
  
  // Restaurant specific fields
  final String? restaurantName;
  final String? restaurantAddress;
  final String? businessLicense;
  
  // Leader specific fields
  final String? areaCode;
  final List<String>? managedDrivers;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.vehicleType,
    this.vehicleNumber,
    this.driverLicense,
    this.restaurantName,
    this.restaurantAddress,
    this.businessLicense,
    this.areaCode,
    this.managedDrivers,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    UserStatus? status,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? vehicleType,
    String? vehicleNumber,
    String? driverLicense,
    String? restaurantName,
    String? restaurantAddress,
    String? businessLicense,
    String? areaCode,
    List<String>? managedDrivers,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      driverLicense: driverLicense ?? this.driverLicense,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      businessLicense: businessLicense ?? this.businessLicense,
      areaCode: areaCode ?? this.areaCode,
      managedDrivers: managedDrivers ?? this.managedDrivers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        status,
        avatar,
        createdAt,
        updatedAt,
        vehicleType,
        vehicleNumber,
        driverLicense,
        restaurantName,
        restaurantAddress,
        businessLicense,
        areaCode,
        managedDrivers,
      ];
}

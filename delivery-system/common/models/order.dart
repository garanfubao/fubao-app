import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'order.g.dart';

enum OrderStatus {
  created,      // Đơn mới tạo
  confirmed,    // Quán xác nhận
  pooled,       // Đưa vào pool chờ tài xế
  assigned,     // Đã gán tài xế
  pickedUp,     // Tài xế đã lấy hàng
  delivered,    // Đã giao thành công
  cancelled     // Đã hủy
}

enum PaymentMethod { cash, card, wallet }

enum PaymentStatus { pending, paid, failed, refunded }

@JsonSerializable()
class OrderItem extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String? note;

  const OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.note,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  double get totalPrice => quantity * price;

  @override
  List<Object?> get props => [id, name, quantity, price, note];
}

@JsonSerializable()
class Address extends Equatable {
  final String address;
  final double latitude;
  final double longitude;
  final String? note;

  const Address({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.note,
  });

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  @override
  List<Object?> get props => [address, latitude, longitude, note];
}

@JsonSerializable()
class Order extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String restaurantId;
  final String restaurantName;
  final String? driverId;
  final String? driverName;
  final List<OrderItem> items;
  final Address restaurantAddress;
  final Address deliveryAddress;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final double itemsTotal;
  final double deliveryFee;
  final double tax;
  final double discount;
  final double total;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancelReason;

  const Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.restaurantId,
    required this.restaurantName,
    this.driverId,
    this.driverName,
    required this.items,
    required this.restaurantAddress,
    required this.deliveryAddress,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.itemsTotal,
    required this.deliveryFee,
    required this.tax,
    required this.discount,
    required this.total,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelReason,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? restaurantId,
    String? restaurantName,
    String? driverId,
    String? driverName,
    List<OrderItem>? items,
    Address? restaurantAddress,
    Address? deliveryAddress,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    double? itemsTotal,
    double? deliveryFee,
    double? tax,
    double? discount,
    double? total,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? assignedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? cancelReason,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      items: items ?? this.items,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      itemsTotal: itemsTotal ?? this.itemsTotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      assignedAt: assignedAt ?? this.assignedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        customerPhone,
        restaurantId,
        restaurantName,
        driverId,
        driverName,
        items,
        restaurantAddress,
        deliveryAddress,
        status,
        paymentMethod,
        paymentStatus,
        itemsTotal,
        deliveryFee,
        tax,
        discount,
        total,
        note,
        createdAt,
        updatedAt,
        confirmedAt,
        assignedAt,
        pickedUpAt,
        deliveredAt,
        cancelledAt,
        cancelReason,
      ];
}

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'wallet.g.dart';

enum TransactionType {
  deposit,        // Nạp tiền
  withdraw,       // Rút tiền
  payment,        // Thanh toán đơn hàng
  refund,         // Hoàn tiền
  commission,     // Hoa hồng tài xế
  fee,            // Phí hệ thống
  bonus,          // Thưởng
  penalty         // Phạt
}

enum TransactionStatus { pending, completed, failed, cancelled }

@JsonSerializable()
class Transaction extends Equatable {
  final String id;
  final String userId;
  final String? orderId;
  final TransactionType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final TransactionStatus status;
  final String description;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.userId,
    this.orderId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.status,
    required this.description,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  Transaction copyWith({
    String? id,
    String? userId,
    String? orderId,
    TransactionType? type,
    double? amount,
    double? balanceBefore,
    double? balanceAfter,
    TransactionStatus? status,
    String? description,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceBefore: balanceBefore ?? this.balanceBefore,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      status: status ?? this.status,
      description: description ?? this.description,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        orderId,
        type,
        amount,
        balanceBefore,
        balanceAfter,
        status,
        description,
        note,
        createdAt,
        updatedAt,
      ];
}

@JsonSerializable()
class Wallet extends Equatable {
  final String id;
  final String userId;
  final double balance;
  final double totalEarnings;
  final double totalWithdrawals;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.totalEarnings,
    required this.totalWithdrawals,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
  Map<String, dynamic> toJson() => _$WalletToJson(this);

  Wallet copyWith({
    String? id,
    String? userId,
    double? balance,
    double? totalEarnings,
    double? totalWithdrawals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        balance,
        totalEarnings,
        totalWithdrawals,
        createdAt,
        updatedAt,
      ];
}

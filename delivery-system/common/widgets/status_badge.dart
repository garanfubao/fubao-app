import 'package:flutter/material.dart';
import '../models/index.dart';
import '../utils/index.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final EdgeInsets? padding;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.padding,
    this.isCompact = false,
  });

  factory StatusBadge.orderStatus(OrderStatus status) {
    final statusText = _getOrderStatusText(status);
    final statusColor = _getOrderStatusColor(status);
    
    return StatusBadge(
      text: statusText,
      color: statusColor,
      textColor: Colors.white,
    );
  }

  factory StatusBadge.userStatus(UserStatus status) {
    final statusText = _getUserStatusText(status);
    final statusColor = _getUserStatusColor(status);
    
    return StatusBadge(
      text: statusText,
      color: statusColor,
      textColor: Colors.white,
    );
  }

  static String _getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.created:
        return AppStrings.orderCreated;
      case OrderStatus.confirmed:
        return AppStrings.orderConfirmed;
      case OrderStatus.pooled:
        return AppStrings.orderPooled;
      case OrderStatus.assigned:
        return AppStrings.orderAssigned;
      case OrderStatus.pickedUp:
        return AppStrings.orderPickedUp;
      case OrderStatus.delivered:
        return AppStrings.orderDelivered;
      case OrderStatus.cancelled:
        return AppStrings.orderCancelled;
    }
  }

  static Color _getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.created:
        return AppTheme.orderStatusColors['created']!;
      case OrderStatus.confirmed:
        return AppTheme.orderStatusColors['confirmed']!;
      case OrderStatus.pooled:
        return AppTheme.orderStatusColors['pooled']!;
      case OrderStatus.assigned:
        return AppTheme.orderStatusColors['assigned']!;
      case OrderStatus.pickedUp:
        return AppTheme.orderStatusColors['pickedUp']!;
      case OrderStatus.delivered:
        return AppTheme.orderStatusColors['delivered']!;
      case OrderStatus.cancelled:
        return AppTheme.orderStatusColors['cancelled']!;
    }
  }

  static String _getUserStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'Hoạt động';
      case UserStatus.inactive:
        return 'Không hoạt động';
      case UserStatus.banned:
        return 'Bị cấm';
    }
  }

  static Color _getUserStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return AppTheme.successColor;
      case UserStatus.inactive:
        return AppTheme.warningColor;
      case UserStatus.banned:
        return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: isCompact ? AppTheme.spacingS : AppTheme.spacingM,
        vertical: isCompact ? AppTheme.spacingXS : AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: color ?? AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(
          isCompact ? AppTheme.radiusS : AppTheme.radiusM,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: isCompact ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

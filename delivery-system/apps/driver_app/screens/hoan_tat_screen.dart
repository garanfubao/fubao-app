import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/index.dart';
import '../../../common/services/index.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

final completedOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final apiService = ApiService();
  final authService = AuthService();
  final currentUser = authService.currentUser;
  
  if (currentUser == null) return [];
  
  final orders = await apiService.getOrders(driverId: currentUser.id);
  return orders.where((order) => 
    order.status == OrderStatus.delivered || 
    order.status == OrderStatus.cancelled
  ).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
});

class HoanTatScreen extends ConsumerWidget {
  const HoanTatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(completedOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hoàn tất'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(completedOrdersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) => _buildOrdersList(context, ref, orders),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: AppTheme.errorColor),
              const SizedBox(height: AppTheme.spacingM),
              Text('Lỗi: $error'),
              const SizedBox(height: AppTheme.spacingM),
              AppButton(
                text: 'Thử lại',
                onPressed: () => ref.refresh(completedOrdersProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, WidgetRef ref, List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppTheme.textSecondaryColor),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Chưa có đơn hàng hoàn tất',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(completedOrdersProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(context, orders[index]),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final isDelivered = order.status == OrderStatus.delivered;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: () => _showOrderDetails(context, order),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppFormatters.formatOrderId(order.id),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StatusBadge.orderStatus(order.status),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Customer info
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  order.customerName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          
          // Restaurant name
          Row(
            children: [
              const Icon(Icons.restaurant, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  order.restaurantName,
                  style: const TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          
          // Completion time
          Row(
            children: [
              Icon(
                isDelivered ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: isDelivered ? AppTheme.successColor : AppTheme.errorColor,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                isDelivered 
                  ? 'Hoàn tất: ${AppFormatters.formatDateTime(order.deliveredAt!)}'
                  : 'Đã hủy: ${AppFormatters.formatDateTime(order.cancelledAt!)}',
                style: TextStyle(
                  color: isDelivered ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng tiền',
                      style: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                    Text(
                      AppFormatters.formatMoney(order.total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDelivered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: AppTheme.spacingXS),
                      Text(
                        '+${AppFormatters.formatMoney(order.deliveryFee * 0.8)}', // 80% commission
                        style: const TextStyle(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textDisabledColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              const Text(
                'Chi tiết đơn hàng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Timeline
                    _buildTimeline(order),
                    const SizedBox(height: AppTheme.spacingL),
                    
                    // Order summary
                    _buildOrderSummary(order),
                    const SizedBox(height: AppTheme.spacingL),
                    
                    // Customer info
                    _buildCustomerInfo(order),
                    const SizedBox(height: AppTheme.spacingL),
                    
                    // Items
                    _buildOrderItems(order),
                    const SizedBox(height: AppTheme.spacingL),
                    
                    // Commission info (if delivered)
                    if (order.status == OrderStatus.delivered)
                      _buildCommissionInfo(order),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(Order order) {
    final events = <Map<String, dynamic>>[];
    
    events.add({
      'title': 'Đơn hàng được tạo',
      'time': order.createdAt,
      'icon': Icons.receipt_long,
      'color': AppTheme.textSecondaryColor,
    });
    
    if (order.confirmedAt != null) {
      events.add({
        'title': 'Quán xác nhận',
        'time': order.confirmedAt,
        'icon': Icons.restaurant,
        'color': AppTheme.primaryColor,
      });
    }
    
    if (order.assignedAt != null) {
      events.add({
        'title': 'Tài xế nhận đơn',
        'time': order.assignedAt,
        'icon': Icons.person,
        'color': AppTheme.primaryColor,
      });
    }
    
    if (order.pickedUpAt != null) {
      events.add({
        'title': 'Đã lấy hàng',
        'time': order.pickedUpAt,
        'icon': Icons.local_shipping,
        'color': AppTheme.warningColor,
      });
    }
    
    if (order.deliveredAt != null) {
      events.add({
        'title': 'Giao hàng thành công',
        'time': order.deliveredAt,
        'icon': Icons.check_circle,
        'color': AppTheme.successColor,
      });
    } else if (order.cancelledAt != null) {
      events.add({
        'title': 'Đơn hàng bị hủy',
        'time': order.cancelledAt,
        'icon': Icons.cancel,
        'color': AppTheme.errorColor,
      });
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch sử đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          ...events.map((event) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: event['color'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    event['icon'],
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        AppFormatters.formatDateTime(event['time']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tóm tắt đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildDetailRow('Mã đơn', AppFormatters.formatOrderId(order.id)),
          _buildDetailRow('Trạng thái', _getStatusText(order.status)),
          _buildDetailRow('Tổng tiền', AppFormatters.formatMoney(order.total)),
          if (order.status == OrderStatus.cancelled && order.cancelReason?.isNotEmpty == true)
            _buildDetailRow('Lý do hủy', order.cancelReason!),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin khách hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildDetailRow('Tên khách hàng', order.customerName),
          _buildDetailRow('Số điện thoại', AppFormatters.formatPhoneNumber(order.customerPhone)),
          _buildDetailRow('Địa chỉ giao hàng', order.deliveryAddress.address),
        ],
      ),
    );
  }

  Widget _buildOrderItems(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Món ăn đã đặt',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: Row(
              children: [
                Expanded(
                  child: Text('${item.name} x${item.quantity}'),
                ),
                Text(
                  AppFormatters.formatMoney(item.totalPrice),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )),
          const Divider(),
          _buildDetailRow('Tiền món ăn', AppFormatters.formatMoney(order.itemsTotal)),
          _buildDetailRow('Phí giao hàng', AppFormatters.formatMoney(order.deliveryFee)),
          _buildDetailRow('Thuế', AppFormatters.formatMoney(order.tax)),
          const Divider(),
          _buildDetailRow(
            'Tổng cộng',
            AppFormatters.formatMoney(order.total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionInfo(Order order) {
    final commission = order.deliveryFee * 0.8; // 80% of delivery fee
    
    return AppCard(
      color: AppTheme.successColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.monetization_on, color: AppTheme.successColor),
              SizedBox(width: AppTheme.spacingS),
              Text(
                'Hoa hồng của bạn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildDetailRow('Phí giao hàng', AppFormatters.formatMoney(order.deliveryFee)),
          _buildDetailRow('Tỷ lệ hoa hồng', '80%'),
          const Divider(),
          _buildDetailRow(
            'Hoa hồng nhận được',
            AppFormatters.formatMoney(commission),
            isBold: true,
            valueColor: AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? (isBold ? AppTheme.primaryColor : AppTheme.textPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return 'Đã giao thành công';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      default:
        return status.name;
    }
  }
}

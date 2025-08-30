import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/index.dart';
import '../../../common/services/index.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

final activeOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final apiService = ApiService();
  final authService = AuthService();
  final currentUser = authService.currentUser;
  
  if (currentUser == null) return [];
  
  final orders = await apiService.getOrders(driverId: currentUser.id);
  return orders.where((order) => 
    order.status == OrderStatus.assigned || 
    order.status == OrderStatus.pickedUp
  ).toList();
});

class DangGiaoScreen extends ConsumerWidget {
  const DangGiaoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(activeOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đang giao hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(activeOrdersProvider),
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
                onPressed: () => ref.refresh(activeOrdersProvider),
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
            Icon(Icons.delivery_dining, size: 64, color: AppTheme.textSecondaryColor),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Không có đơn hàng đang giao',
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
      onRefresh: () async => ref.refresh(activeOrdersProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(context, ref, orders[index]),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, Order order) {
    final isPickedUp = order.status == OrderStatus.pickedUp;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: () => _showOrderDetails(context, ref, order),
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
                  '${order.customerName} • ${AppFormatters.formatPhoneNumber(order.customerPhone)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          
          // Current step
          Row(
            children: [
              Icon(
                isPickedUp ? Icons.delivery_dining : Icons.restaurant,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  isPickedUp 
                    ? 'Đang giao đến: ${order.deliveryAddress.address}'
                    : 'Lấy hàng tại: ${order.restaurantName}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          
          // Time info
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                isPickedUp 
                  ? 'Đã lấy hàng: ${AppFormatters.formatRelativeTime(order.pickedUpAt!)}'
                  : 'Nhận đơn: ${AppFormatters.formatRelativeTime(order.assignedAt!)}',
                style: const TextStyle(color: AppTheme.textSecondaryColor),
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
              Row(
                children: [
                  IconButton(
                    onPressed: () => _callCustomer(order.customerPhone),
                    icon: const Icon(Icons.phone, color: AppTheme.successColor),
                  ),
                  IconButton(
                    onPressed: () => _openMap(order),
                    icon: const Icon(Icons.map, color: AppTheme.primaryColor),
                  ),
                  AppButton(
                    text: isPickedUp ? 'Đã giao' : 'Đã lấy',
                    onPressed: () => _updateOrderStatus(context, ref, order),
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, WidgetRef ref, Order order) {
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
                    // Progress indicator
                    _buildProgressIndicator(order),
                    const SizedBox(height: AppTheme.spacingL),
                    
                    // Customer info
                    _buildCustomerInfo(order),
                    const SizedBox(height: AppTheme.spacingL),
                    
                    // Restaurant info
                    _buildRestaurantInfo(order),
                    const SizedBox(height: AppTheme.spacingL),
                    
                    // Items
                    _buildOrderItems(order),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Gọi khách hàng',
                      type: AppButtonType.outline,
                      icon: Icons.phone,
                      onPressed: () => _callCustomer(order.customerPhone),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: AppButton(
                      text: order.status == OrderStatus.pickedUp ? 'Đã giao hàng' : 'Đã lấy hàng',
                      onPressed: () {
                        Navigator.pop(context);
                        _updateOrderStatus(context, ref, order);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(Order order) {
    final steps = [
      {'title': 'Nhận đơn', 'completed': true},
      {'title': 'Lấy hàng', 'completed': order.status.index >= OrderStatus.pickedUp.index},
      {'title': 'Giao hàng', 'completed': order.status.index >= OrderStatus.delivered.index},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiến trình giao hàng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: steps.map((step) {
            final index = steps.indexOf(step);
            final isCompleted = step['completed'] as bool;
            
            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppTheme.successColor : AppTheme.textDisabledColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted ? AppTheme.successColor : AppTheme.textDisabledColor,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Row(
          children: steps.map((step) => Expanded(
            child: Text(
              step['title'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: (step['completed'] as bool) 
                  ? AppTheme.textPrimaryColor 
                  : AppTheme.textSecondaryColor,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person, color: AppTheme.primaryColor),
              SizedBox(width: AppTheme.spacingS),
              Text(
                'Thông tin khách hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text('Tên: ${order.customerName}'),
          const SizedBox(height: AppTheme.spacingS),
          Text('SĐT: ${AppFormatters.formatPhoneNumber(order.customerPhone)}'),
          const SizedBox(height: AppTheme.spacingS),
          Text('Địa chỉ: ${order.deliveryAddress.address}'),
          if (order.note?.isNotEmpty == true) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text('Ghi chú: ${order.note}'),
          ],
        ],
      ),
    );
  }

  Widget _buildRestaurantInfo(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.restaurant, color: AppTheme.primaryColor),
              SizedBox(width: AppTheme.spacingS),
              Text(
                'Thông tin quán ăn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text('Tên quán: ${order.restaurantName}'),
          const SizedBox(height: AppTheme.spacingS),
          Text('Địa chỉ: ${order.restaurantAddress.address}'),
        ],
      ),
    );
  }

  Widget _buildOrderItems(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt, color: AppTheme.primaryColor),
              SizedBox(width: AppTheme.spacingS),
              Text(
                'Món ăn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tổng cộng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                AppFormatters.formatMoney(order.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _callCustomer(String phoneNumber) {
    // TODO: Implement phone call functionality
    // launch('tel:$phoneNumber');
  }

  void _openMap(Order order) {
    // TODO: Implement map navigation
    // final url = 'https://www.google.com/maps/dir/?api=1&destination=${order.deliveryAddress.latitude},${order.deliveryAddress.longitude}';
    // launch(url);
  }

  Future<void> _updateOrderStatus(BuildContext context, WidgetRef ref, Order order) async {
    try {
      final apiService = ApiService();
      final newStatus = order.status == OrderStatus.assigned 
        ? OrderStatus.pickedUp 
        : OrderStatus.delivered;
      
      await apiService.updateOrderStatus(order.id, newStatus);
      
      // Refresh the orders list
      ref.refresh(activeOrdersProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == OrderStatus.pickedUp 
                ? 'Đã xác nhận lấy hàng!' 
                : 'Đã xác nhận giao hàng thành công!',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}

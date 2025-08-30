import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/index.dart';
import '../../../common/services/index.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

final newOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final apiService = ApiService();
  final authService = AuthService();
  final currentUser = authService.currentUser;
  
  if (currentUser == null) return [];
  
  return await apiService.getOrders(
    restaurantId: currentUser.id,
  );
});

class DonMoiScreen extends ConsumerWidget {
  const DonMoiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(newOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng mới'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(newOrdersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          final newOrders = orders.where((order) => 
            order.status == OrderStatus.created
          ).toList();
          
          return _buildOrdersList(context, ref, newOrders);
        },
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
                onPressed: () => ref.refresh(newOrdersProvider),
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
            Icon(Icons.assignment, size: 64, color: AppTheme.textSecondaryColor),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Không có đơn hàng mới',
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
      onRefresh: () async => ref.refresh(newOrdersProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(context, ref, orders[index]),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, Order order) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
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
          
          // Order time
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Đặt lúc: ${AppFormatters.formatDateTime(order.createdAt)}',
                style: const TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Items summary
          Text(
            '${order.items.length} món • ${AppFormatters.formatMoney(order.total)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Từ chối',
                  type: AppButtonType.outline,
                  customColor: AppTheme.errorColor,
                  onPressed: () => _rejectOrder(context, ref, order),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: AppButton(
                  text: 'Xác nhận',
                  onPressed: () => _confirmOrder(context, ref, order),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context, WidgetRef ref, Order order) async {
    try {
      final apiService = ApiService();
      await apiService.updateOrderStatus(order.id, OrderStatus.confirmed);
      
      ref.refresh(newOrdersProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xác nhận đơn hàng!'),
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

  Future<void> _rejectOrder(BuildContext context, WidgetRef ref, Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối đơn hàng'),
        content: Text('Bạn có chắc muốn từ chối đơn hàng ${AppFormatters.formatOrderId(order.id)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Từ chối',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final apiService = ApiService();
        await apiService.updateOrderStatus(order.id, OrderStatus.cancelled);
        
        ref.refresh(newOrdersProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã từ chối đơn hàng'),
              backgroundColor: AppTheme.errorColor,
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
}

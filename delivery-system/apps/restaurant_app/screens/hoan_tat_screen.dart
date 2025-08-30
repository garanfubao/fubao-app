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
  
  final orders = await apiService.getOrders(restaurantId: currentUser.id);
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
        data: (orders) => _buildOrdersList(context, orders),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: AppButton(
            text: 'Thử lại',
            onPressed: () => ref.refresh(completedOrdersProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('Chưa có đơn hàng hoàn tất'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: orders.length,
      itemBuilder: (context, index) => AppCard(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppFormatters.formatOrderId(orders[index].id),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                StatusBadge.orderStatus(orders[index].status),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text('Khách hàng: ${orders[index].customerName}'),
            const SizedBox(height: AppTheme.spacingS),
            Text('Tổng tiền: ${AppFormatters.formatMoney(orders[index].total)}'),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              orders[index].status == OrderStatus.delivered
                ? 'Hoàn tất: ${AppFormatters.formatDateTime(orders[index].deliveredAt!)}'
                : 'Đã hủy: ${AppFormatters.formatDateTime(orders[index].cancelledAt!)}',
              style: TextStyle(
                color: orders[index].status == OrderStatus.delivered 
                  ? AppTheme.successColor 
                  : AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

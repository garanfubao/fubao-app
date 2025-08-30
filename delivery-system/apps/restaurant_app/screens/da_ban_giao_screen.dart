import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/index.dart';
import '../../../common/services/index.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

final handedOverOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final apiService = ApiService();
  final authService = AuthService();
  final currentUser = authService.currentUser;
  
  if (currentUser == null) return [];
  
  final orders = await apiService.getOrders(restaurantId: currentUser.id);
  return orders.where((order) => 
    order.status == OrderStatus.assigned || 
    order.status == OrderStatus.pickedUp
  ).toList();
});

class DaBanGiaoScreen extends ConsumerWidget {
  const DaBanGiaoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(handedOverOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đã bàn giao'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(handedOverOrdersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) => _buildOrdersList(context, orders),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: AppButton(
            text: 'Thử lại',
            onPressed: () => ref.refresh(handedOverOrdersProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('Không có đơn hàng đã bàn giao'),
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
            if (orders[index].driverName != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text('Tài xế: ${orders[index].driverName}'),
            ],
            const SizedBox(height: AppTheme.spacingS),
            Text('Tổng tiền: ${AppFormatters.formatMoney(orders[index].total)}'),
            if (orders[index].assignedAt != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Giao cho tài xế: ${AppFormatters.formatRelativeTime(orders[index].assignedAt!)}',
                style: const TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

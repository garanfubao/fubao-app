import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/index.dart';
import '../../../common/services/index.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

final preparingOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final apiService = ApiService();
  final authService = AuthService();
  final currentUser = authService.currentUser;
  
  if (currentUser == null) return [];
  
  final orders = await apiService.getOrders(restaurantId: currentUser.id);
  return orders.where((order) => order.status == OrderStatus.confirmed).toList();
});

class DangChuanBiScreen extends ConsumerWidget {
  const DangChuanBiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(preparingOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đang chuẩn bị'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(preparingOrdersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) => _buildOrdersList(context, ref, orders),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: AppButton(
            text: 'Thử lại',
            onPressed: () => ref.refresh(preparingOrdersProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, WidgetRef ref, List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('Không có đơn hàng đang chuẩn bị'),
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
            Text(
              AppFormatters.formatOrderId(orders[index].id),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(orders[index].customerName),
            const SizedBox(height: AppTheme.spacingS),
            Text('${orders[index].items.length} món'),
            const SizedBox(height: AppTheme.spacingM),
            AppButton(
              text: 'Hoàn tất chuẩn bị',
              onPressed: () => _completePreparation(context, ref, orders[index]),
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completePreparation(BuildContext context, WidgetRef ref, Order order) async {
    try {
      final apiService = ApiService();
      await apiService.updateOrderStatus(order.id, OrderStatus.pooled);
      ref.refresh(preparingOrdersProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hoàn tất chuẩn bị!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
}

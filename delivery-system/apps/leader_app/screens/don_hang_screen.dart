import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/index.dart';
import '../../../common/services/index.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

final allOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final apiService = ApiService();
  return await apiService.getOrders();
});

final orderStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final apiService = ApiService();
  final orders = await apiService.getOrders();
  
  final stats = <String, int>{};
  for (final status in OrderStatus.values) {
    stats[status.name] = orders.where((order) => order.status == status).length;
  }
  
  return stats;
});

class DonHangScreen extends ConsumerStatefulWidget {
  const DonHangScreen({super.key});

  @override
  ConsumerState<DonHangScreen> createState() => _DonHangScreenState();
}

class _DonHangScreenState extends ConsumerState<DonHangScreen> {
  OrderStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allOrdersProvider);
    final statsAsync = ref.watch(orderStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(allOrdersProvider);
              ref.refresh(orderStatsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats cards
          statsAsync.when(
            data: (stats) => _buildStatsSection(stats),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          
          // Filters
          _buildFiltersSection(),
          
          // Orders list
          Expanded(
            child: ordersAsync.when(
              data: (orders) => _buildOrdersList(context, orders),
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
                      onPressed: () => ref.refresh(allOrdersProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Chờ xác nhận',
              stats['created'] ?? 0,
              AppTheme.textSecondaryColor,
              Icons.pending,
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: _buildStatCard(
              'Đang giao',
              (stats['assigned'] ?? 0) + (stats['pickedUp'] ?? 0),
              AppTheme.warningColor,
              Icons.delivery_dining,
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: _buildStatCard(
              'Hoàn thành',
              stats['delivered'] ?? 0,
              AppTheme.successColor,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: _buildStatCard(
              'Đã hủy',
              stats['cancelled'] ?? 0,
              AppTheme.errorColor,
              Icons.cancel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm đơn hàng...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          PopupMenuButton<OrderStatus?>(
            initialValue: _selectedStatus,
            onSelected: (status) => setState(() => _selectedStatus = status),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.textDisabledColor),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 20,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    _selectedStatus == null ? 'Tất cả' : _getStatusText(_selectedStatus!),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Tất cả trạng thái'),
              ),
              ...OrderStatus.values.map((status) => PopupMenuItem(
                value: status,
                child: Text(_getStatusText(status)),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<Order> orders) {
    // Filter orders
    var filteredOrders = orders;
    
    if (_selectedStatus != null) {
      filteredOrders = filteredOrders.where((order) => order.status == _selectedStatus).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) =>
        order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        order.restaurantName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (filteredOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: AppTheme.textSecondaryColor),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Không tìm thấy đơn hàng',
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
      onRefresh: () async => ref.refresh(allOrdersProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) => _buildOrderCard(context, filteredOrders[index]),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
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
          
          // Customer and restaurant info
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
          
          if (order.driverName != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                const Icon(Icons.delivery_dining, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    order.driverName!,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: AppTheme.spacingM),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.formatDateTime(order.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      AppFormatters.formatMoney(order.total),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (order.status == OrderStatus.pooled)
                AppButton(
                  text: 'Gán tài xế',
                  onPressed: () => _showAssignDriverDialog(context, order),
                  size: AppButtonSize.small,
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
              
              Text(
                'Chi tiết đơn hàng ${AppFormatters.formatOrderId(order.id)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailSection('Trạng thái', [
                      Row(
                        children: [
                          StatusBadge.orderStatus(order.status),
                          const SizedBox(width: AppTheme.spacingM),
                          Text(AppFormatters.formatRelativeTime(order.updatedAt)),
                        ],
                      ),
                    ]),
                    
                    _buildDetailSection('Thông tin khách hàng', [
                      _buildDetailRow('Tên', order.customerName),
                      _buildDetailRow('SĐT', AppFormatters.formatPhoneNumber(order.customerPhone)),
                      _buildDetailRow('Địa chỉ', order.deliveryAddress.address),
                    ]),
                    
                    _buildDetailSection('Thông tin quán', [
                      _buildDetailRow('Tên quán', order.restaurantName),
                      _buildDetailRow('Địa chỉ', order.restaurantAddress.address),
                    ]),
                    
                    if (order.driverName != null)
                      _buildDetailSection('Tài xế', [
                        _buildDetailRow('Tên tài xế', order.driverName!),
                        if (order.assignedAt != null)
                          _buildDetailRow('Thời gian nhận', AppFormatters.formatDateTime(order.assignedAt!)),
                      ]),
                    
                    _buildDetailSection('Món ăn', 
                      order.items.map((item) => 
                        _buildDetailRow('${item.name} x${item.quantity}', AppFormatters.formatMoney(item.totalPrice))
                      ).toList(),
                    ),
                    
                    _buildDetailSection('Thanh toán', [
                      _buildDetailRow('Tiền món', AppFormatters.formatMoney(order.itemsTotal)),
                      _buildDetailRow('Phí giao hàng', AppFormatters.formatMoney(order.deliveryFee)),
                      _buildDetailRow('Thuế', AppFormatters.formatMoney(order.tax)),
                      const Divider(),
                      _buildDetailRow('Tổng cộng', AppFormatters.formatMoney(order.total), isBold: true),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...children,
        const SizedBox(height: AppTheme.spacingL),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignDriverDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gán tài xế cho ${AppFormatters.formatOrderId(order.id)}'),
        content: const Text('Tính năng gán tài xế đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.created:
        return 'Mới tạo';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.pooled:
        return 'Chờ tài xế';
      case OrderStatus.assigned:
        return 'Đã gán tài xế';
      case OrderStatus.pickedUp:
        return 'Đã lấy hàng';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/index.dart';
import '../../../common/services/index.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

final driversProvider = FutureProvider<List<User>>((ref) async {
  final apiService = ApiService();
  return await apiService.getUsers(role: UserRole.driver);
});

final driverStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, driverId) async {
  final apiService = ApiService();
  final orders = await apiService.getOrders(driverId: driverId);
  final wallet = await apiService.getWalletByUserId(driverId);
  
  final today = DateTime.now();
  final todayOrders = orders.where((order) => 
    order.createdAt.day == today.day &&
    order.createdAt.month == today.month &&
    order.createdAt.year == today.year
  ).toList();
  
  final completedToday = todayOrders.where((order) => order.status == OrderStatus.delivered).length;
  final totalCompleted = orders.where((order) => order.status == OrderStatus.delivered).length;
  
  return {
    'todayOrders': completedToday,
    'totalOrders': totalCompleted,
    'todayEarnings': todayOrders
        .where((order) => order.status == OrderStatus.delivered)
        .fold<double>(0, (sum, order) => sum + (order.deliveryFee * 0.8)),
    'totalEarnings': wallet?.totalEarnings ?? 0,
    'currentBalance': wallet?.balance ?? 0,
    'isOnline': true, // Mock online status
  };
});

class TaiXeScreen extends ConsumerStatefulWidget {
  const TaiXeScreen({super.key});

  @override
  ConsumerState<TaiXeScreen> createState() => _TaiXeScreenState();
}

class _TaiXeScreenState extends ConsumerState<TaiXeScreen> {
  String _searchQuery = '';
  UserStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(driversProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tài xế'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDriverDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(driversProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter
          _buildSearchSection(),
          
          // Drivers list
          Expanded(
            child: driversAsync.when(
              data: (drivers) => _buildDriversList(context, drivers),
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
                      onPressed: () => ref.refresh(driversProvider),
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

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm tài xế...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          PopupMenuButton<UserStatus?>(
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
              ...UserStatus.values.map((status) => PopupMenuItem(
                value: status,
                child: Text(_getStatusText(status)),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriversList(BuildContext context, List<User> drivers) {
    // Filter drivers
    var filteredDrivers = drivers;
    
    if (_selectedStatus != null) {
      filteredDrivers = filteredDrivers.where((driver) => driver.status == _selectedStatus).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filteredDrivers = filteredDrivers.where((driver) =>
        driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        driver.phone.contains(_searchQuery) ||
        (driver.vehicleNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    if (filteredDrivers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: AppTheme.textSecondaryColor),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Không tìm thấy tài xế',
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
      onRefresh: () async => ref.refresh(driversProvider),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        itemCount: filteredDrivers.length,
        itemBuilder: (context, index) => _buildDriverCard(context, filteredDrivers[index]),
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, User driver) {
    final statsAsync = ref.watch(driverStatsProvider(driver.id));
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: () => _showDriverDetails(context, driver),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: driver.avatar != null
                    ? ClipOval(
                        child: Image.network(
                          driver.avatar!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        driver.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              
              // Driver info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            driver.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        StatusBadge.userStatus(driver.status),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      AppFormatters.formatPhoneNumber(driver.phone),
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    if (driver.vehicleNumber != null) ...[
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        AppFormatters.formatVehicleNumber(driver.vehicleNumber!),
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Online status
              statsAsync.when(
                data: (stats) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: stats['isOnline'] 
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.textDisabledColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: stats['isOnline'] ? AppTheme.successColor : AppTheme.textDisabledColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingXS),
                      Text(
                        stats['isOnline'] ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 10,
                          color: stats['isOnline'] ? AppTheme.successColor : AppTheme.textDisabledColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Stats
          statsAsync.when(
            data: (stats) => Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Hôm nay',
                    '${stats['todayOrders']} đơn',
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Tổng cộng',
                    '${stats['totalOrders']} đơn',
                    AppTheme.textSecondaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Thu nhập',
                    AppFormatters.formatMoney(stats['totalEarnings']),
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox(height: 40),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showDriverDetails(BuildContext context, User driver) {
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
              
              // Driver header
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: driver.avatar != null
                        ? ClipOval(
                            child: Image.network(
                              driver.avatar!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            driver.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        StatusBadge.userStatus(driver.status),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailSection('Thông tin cá nhân', [
                      _buildDetailRow('Họ tên', driver.name),
                      _buildDetailRow('Số điện thoại', AppFormatters.formatPhoneNumber(driver.phone)),
                      _buildDetailRow('Email', driver.email),
                      _buildDetailRow('Ngày tham gia', AppFormatters.formatDate(driver.createdAt)),
                    ]),
                    
                    if (driver.vehicleType != null || driver.vehicleNumber != null || driver.driverLicense != null)
                      _buildDetailSection('Thông tin xe', [
                        if (driver.vehicleType != null)
                          _buildDetailRow('Loại xe', driver.vehicleType!),
                        if (driver.vehicleNumber != null)
                          _buildDetailRow('Biển số', AppFormatters.formatVehicleNumber(driver.vehicleNumber!)),
                        if (driver.driverLicense != null)
                          _buildDetailRow('Bằng lái', driver.driverLicense!),
                      ]),
                    
                    // Performance stats
                    Consumer(
                      builder: (context, ref, child) {
                        final statsAsync = ref.watch(driverStatsProvider(driver.id));
                        return statsAsync.when(
                          data: (stats) => _buildDetailSection('Thống kê hiệu suất', [
                            _buildDetailRow('Đơn hôm nay', '${stats['todayOrders']} đơn'),
                            _buildDetailRow('Tổng đơn đã giao', '${stats['totalOrders']} đơn'),
                            _buildDetailRow('Thu nhập hôm nay', AppFormatters.formatMoney(stats['todayEarnings'])),
                            _buildDetailRow('Tổng thu nhập', AppFormatters.formatMoney(stats['totalEarnings'])),
                            _buildDetailRow('Số dư hiện tại', AppFormatters.formatMoney(stats['currentBalance'])),
                          ]),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: driver.status == UserStatus.active ? 'Tạm khóa' : 'Kích hoạt',
                      type: driver.status == UserStatus.active ? AppButtonType.outline : AppButtonType.primary,
                      onPressed: () => _toggleDriverStatus(context, driver),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: AppButton(
                      text: 'Xem chi tiết',
                      onPressed: () => _showDriverFullDetails(context, driver),
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

  Widget _buildDetailRow(String label, String value) {
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
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDriverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm tài xế mới'),
        content: const Text('Tính năng thêm tài xế đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _toggleDriverStatus(BuildContext context, User driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(driver.status == UserStatus.active ? 'Tạm khóa tài xế' : 'Kích hoạt tài xế'),
        content: Text(
          driver.status == UserStatus.active 
            ? 'Bạn có chắc muốn tạm khóa tài xế ${driver.name}?'
            : 'Bạn có chắc muốn kích hoạt tài xế ${driver.name}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    driver.status == UserStatus.active 
                      ? 'Đã tạm khóa tài xế ${driver.name}'
                      : 'Đã kích hoạt tài xế ${driver.name}'
                  ),
                ),
              );
              // TODO: Implement actual status update
              ref.refresh(driversProvider);
            },
            child: Text(
              driver.status == UserStatus.active ? 'Tạm khóa' : 'Kích hoạt',
              style: TextStyle(
                color: driver.status == UserStatus.active 
                  ? AppTheme.errorColor 
                  : AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDriverFullDetails(BuildContext context, User driver) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng xem chi tiết đầy đủ đang được phát triển...'),
      ),
    );
  }

  String _getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'Hoạt động';
      case UserStatus.inactive:
        return 'Không hoạt động';
      case UserStatus.banned:
        return 'Bị cấm';
    }
  }
}

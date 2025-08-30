import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/index.dart';
import '../../../common/services/index.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

final driverStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ApiService();
  final authService = AuthService();
  final currentUser = authService.currentUser;
  
  if (currentUser == null) return {};
  
  // Get driver's orders and wallet
  final orders = await apiService.getOrders(driverId: currentUser.id);
  final wallet = await apiService.getWalletByUserId(currentUser.id);
  
  final todayOrders = orders.where((order) => 
    order.createdAt.day == DateTime.now().day &&
    order.createdAt.month == DateTime.now().month &&
    order.createdAt.year == DateTime.now().year
  ).toList();
  
  final completedToday = todayOrders.where((order) => 
    order.status == OrderStatus.delivered
  ).length;
  
  final totalEarningsToday = todayOrders
    .where((order) => order.status == OrderStatus.delivered)
    .fold<double>(0, (sum, order) => sum + (order.deliveryFee * 0.8));
  
  return {
    'totalOrders': orders.length,
    'todayOrders': completedToday,
    'todayEarnings': totalEarningsToday,
    'totalEarnings': wallet?.totalEarnings ?? 0,
    'currentBalance': wallet?.balance ?? 0,
  };
});

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = AuthService();
    final currentUser = authService.currentUser;
    final statsAsync = ref.watch(driverStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.radiusL),
                  bottomRight: Radius.circular(AppTheme.radiusL),
                ),
              ),
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: currentUser?.avatar != null
                        ? ClipOval(
                            child: Image.network(
                              currentUser!.avatar!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            currentUser?.name.substring(0, 1).toUpperCase() ?? 'D',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    currentUser?.name ?? 'Tài xế',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    currentUser?.phone ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  if (currentUser?.vehicleNumber != null) ...[
                    const SizedBox(height: AppTheme.spacingS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: Text(
                        AppFormatters.formatVehicleNumber(currentUser!.vehicleNumber!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Stats section
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: statsAsync.when(
                data: (stats) => _buildStatsCards(context, stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Container(),
              ),
            ),
            
            // Menu items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: 'Ví của tôi',
                    subtitle: 'Xem số dư và lịch sử giao dịch',
                    onTap: () => _openWallet(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.history,
                    title: 'Lịch sử đơn hàng',
                    subtitle: 'Xem tất cả đơn hàng đã giao',
                    onTap: () => _openOrderHistory(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Thống kê thu nhập',
                    subtitle: 'Báo cáo thu nhập theo ngày, tuần, tháng',
                    onTap: () => _openEarningsReport(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.person,
                    title: 'Thông tin cá nhân',
                    subtitle: 'Cập nhật thông tin và giấy tờ',
                    onTap: () => _openProfile(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings,
                    title: 'Cài đặt',
                    subtitle: 'Thông báo, bảo mật, khác',
                    onTap: () => _openSettings(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help,
                    title: 'Trợ giúp',
                    subtitle: 'Hướng dẫn sử dụng và FAQ',
                    onTap: () => _openHelp(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    subtitle: 'Thoát khỏi tài khoản',
                    onTap: () => _logout(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // App version
            const Text(
              'Phiên bản ${AppConstants.appVersion}',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Hôm nay',
            '${stats['todayOrders']} đơn',
            AppFormatters.formatMoney(stats['todayEarnings']),
            Icons.today,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _buildStatCard(
            'Tổng cộng',
            '${stats['totalOrders']} đơn',
            AppFormatters.formatMoney(stats['totalEarnings']),
            Icons.all_inclusive,
            AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String subtitle, String value, IconData icon, Color color) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDestructive 
                ? AppTheme.errorColor.withOpacity(0.1)
                : AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              icon,
              color: isDestructive ? AppTheme.errorColor : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? AppTheme.errorColor : AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondaryColor,
          ),
        ],
      ),
    );
  }

  void _openWallet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: const Column(
          children: [
            Text(
              'Ví của tôi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingL),
            Expanded(
              child: Center(
                child: Text(
                  'Tính năng ví điện tử đang phát triển...',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openOrderHistory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lịch sử đơn hàng có thể xem tại tab "Hoàn tất"'),
      ),
    );
  }

  void _openEarningsReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: const Column(
          children: [
            Text(
              'Thống kê thu nhập',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingL),
            Expanded(
              child: Center(
                child: Text(
                  'Tính năng thống kê đang phát triển...',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: const Column(
          children: [
            Text(
              'Thông tin cá nhân',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingL),
            Expanded(
              child: Center(
                child: Text(
                  'Tính năng chỉnh sửa thông tin đang phát triển...',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: const Column(
          children: [
            Text(
              'Cài đặt',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingL),
            Expanded(
              child: Center(
                child: Text(
                  'Tính năng cài đặt đang phát triển...',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: const Column(
          children: [
            Text(
              'Trợ giúp',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingL),
            Expanded(
              child: Center(
                child: Text(
                  'Tính năng trợ giúp đang phát triển...',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final authService = AuthService();
              await authService.logout();
              
              if (context.mounted) {
                Navigator.of(context).pop();
                // TODO: Navigate to login screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã đăng xuất thành công'),
                  ),
                );
              }
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

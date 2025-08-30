import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/services/index.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

class MenuMonScreen extends ConsumerWidget {
  const MenuMonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = AuthService();
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu & Cài đặt'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Restaurant header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.successColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.radiusL),
                  bottomRight: Radius.circular(AppTheme.radiusL),
                ),
              ),
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    currentUser?.restaurantName ?? 'Quán ăn',
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
                ],
              ),
            ),
            
            // Menu sections
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                children: [
                  _buildMenuSection(
                    'Quản lý quán',
                    [
                      _buildMenuItem(
                        context,
                        icon: Icons.restaurant_menu,
                        title: 'Menu món ăn',
                        subtitle: 'Quản lý món ăn và giá cả',
                        onTap: () => _showComingSoon(context, 'Menu món ăn'),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.schedule,
                        title: 'Giờ mở cửa',
                        subtitle: 'Cài đặt thời gian hoạt động',
                        onTap: () => _showComingSoon(context, 'Giờ mở cửa'),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.location_on,
                        title: 'Thông tin địa chỉ',
                        subtitle: 'Cập nhật địa chỉ và thông tin liên hệ',
                        onTap: () => _showComingSoon(context, 'Thông tin địa chỉ'),
                      ),
                    ],
                  ),
                  
                  _buildMenuSection(
                    'Báo cáo',
                    [
                      _buildMenuItem(
                        context,
                        icon: Icons.bar_chart,
                        title: 'Doanh thu',
                        subtitle: 'Xem báo cáo doanh thu theo ngày, tuần, tháng',
                        onTap: () => _showComingSoon(context, 'Báo cáo doanh thu'),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.trending_up,
                        title: 'Thống kê đơn hàng',
                        subtitle: 'Phân tích đơn hàng và hiệu suất',
                        onTap: () => _showComingSoon(context, 'Thống kê đơn hàng'),
                      ),
                    ],
                  ),
                  
                  _buildMenuSection(
                    'Tài khoản',
                    [
                      _buildMenuItem(
                        context,
                        icon: Icons.person,
                        title: 'Thông tin quán',
                        subtitle: 'Cập nhật thông tin quán ăn',
                        onTap: () => _showComingSoon(context, 'Thông tin quán'),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.notifications,
                        title: 'Thông báo',
                        subtitle: 'Cài đặt thông báo đơn hàng',
                        onTap: () => _showComingSoon(context, 'Cài đặt thông báo'),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.help,
                        title: 'Trợ giúp',
                        subtitle: 'Hướng dẫn sử dụng và liên hệ hỗ trợ',
                        onTap: () => _showComingSoon(context, 'Trợ giúp'),
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
                ],
              ),
            ),
            
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

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...items,
        const SizedBox(height: AppTheme.spacingL),
      ],
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
                : AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              icon,
              color: isDestructive ? AppTheme.errorColor : AppTheme.successColor,
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

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('Tính năng $feature đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
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

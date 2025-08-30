import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/services/index.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

class CaiDatScreen extends ConsumerWidget {
  const CaiDatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = AuthService();
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.warningColor,
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
                            currentUser?.name.substring(0, 1).toUpperCase() ?? 'L',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warningColor,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    currentUser?.name ?? 'Leader',
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
                  if (currentUser?.areaCode != null) ...[
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
                        'Khu vực: ${currentUser!.areaCode}',
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
            
            // Settings sections
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                children: [
                  _buildSettingsSection(
                    'Quản lý',
                    [
                      _buildSettingsItem(
                        context,
                        icon: Icons.people,
                        title: 'Quản lý tài xế',
                        subtitle: 'Thêm, sửa, xóa tài xế trong khu vực',
                        onTap: () => _navigateToDriverManagement(context),
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.assignment,
                        title: 'Phân công đơn hàng',
                        subtitle: 'Gán đơn hàng cho tài xế',
                        onTap: () => _navigateToOrderAssignment(context),
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.attach_money,
                        title: 'Cài đặt phí',
                        subtitle: 'Cấu hình phí giao hàng và hoa hồng',
                        onTap: () => _navigateToFeeSettings(context),
                      ),
                    ],
                  ),
                  
                  _buildSettingsSection(
                    'Báo cáo & Thống kê',
                    [
                      _buildSettingsItem(
                        context,
                        icon: Icons.bar_chart,
                        title: 'Báo cáo hiệu suất',
                        subtitle: 'Xem báo cáo chi tiết theo thời gian',
                        onTap: () => _navigateToPerformanceReport(context),
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.trending_up,
                        title: 'Thống kê khu vực',
                        subtitle: 'Phân tích dữ liệu khu vực quản lý',
                        onTap: () => _navigateToAreaStats(context),
                      ),
                    ],
                  ),
                  
                  _buildSettingsSection(
                    'Cá nhân',
                    [
                      _buildSettingsItem(
                        context,
                        icon: Icons.person,
                        title: 'Thông tin cá nhân',
                        subtitle: 'Cập nhật thông tin tài khoản',
                        onTap: () => _navigateToProfile(context),
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.notifications,
                        title: 'Thông báo',
                        subtitle: 'Cài đặt thông báo và cảnh báo',
                        onTap: () => _navigateToNotifications(context),
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.security,
                        title: 'Bảo mật',
                        subtitle: 'Đổi mật khẩu và cài đặt bảo mật',
                        onTap: () => _navigateToSecurity(context),
                      ),
                    ],
                  ),
                  
                  _buildSettingsSection(
                    'Khác',
                    [
                      _buildSettingsItem(
                        context,
                        icon: Icons.help,
                        title: 'Trợ giúp',
                        subtitle: 'Hướng dẫn sử dụng và FAQ',
                        onTap: () => _navigateToHelp(context),
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.info,
                        title: 'Về ứng dụng',
                        subtitle: 'Phiên bản ${AppConstants.appVersion}',
                        onTap: () => _showAboutDialog(context),
                      ),
                      _buildSettingsItem(
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
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
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

  Widget _buildSettingsItem(
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
                : AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              icon,
              color: isDestructive ? AppTheme.errorColor : AppTheme.warningColor,
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

  void _navigateToDriverManagement(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng quản lý tài xế có thể truy cập ở tab "Tài xế"'),
      ),
    );
  }

  void _navigateToOrderAssignment(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng phân công đơn hàng có thể truy cập ở tab "Đơn hàng"'),
      ),
    );
  }

  void _navigateToFeeSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng cài đặt phí có thể truy cập ở tab "Phí tài xế"'),
      ),
    );
  }

  void _navigateToPerformanceReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng báo cáo có thể truy cập ở tab "Báo cáo"'),
      ),
    );
  }

  void _navigateToAreaStats(BuildContext context) {
    _showComingSoonDialog(context, 'Thống kê khu vực');
  }

  void _navigateToProfile(BuildContext context) {
    _showComingSoonDialog(context, 'Thông tin cá nhân');
  }

  void _navigateToNotifications(BuildContext context) {
    _showComingSoonDialog(context, 'Cài đặt thông báo');
  }

  void _navigateToSecurity(BuildContext context) {
    _showComingSoonDialog(context, 'Cài đặt bảo mật');
  }

  void _navigateToHelp(BuildContext context) {
    _showComingSoonDialog(context, 'Trợ giúp');
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về ứng dụng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppConstants.appName} - Leader App'),
            SizedBox(height: AppTheme.spacingS),
            Text('Phiên bản: ${AppConstants.appVersion}'),
            SizedBox(height: AppTheme.spacingS),
            Text('Ứng dụng quản lý giao hàng dành cho trưởng nhóm'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

class ReportData {
  final String period;
  final int totalOrders;
  final int completedOrders;
  final double totalRevenue;
  final double totalDriverEarnings;
  final int activeDrivers;
  final double averageDeliveryTime;

  ReportData({
    required this.period,
    required this.totalOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.totalDriverEarnings,
    required this.activeDrivers,
    required this.averageDeliveryTime,
  });
}

final reportDataProvider = FutureProvider.family<ReportData, String>((ref, period) async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  // Mock data based on period
  switch (period) {
    case 'today':
      return ReportData(
        period: 'Hôm nay',
        totalOrders: 45,
        completedOrders: 42,
        totalRevenue: 1250000,
        totalDriverEarnings: 875000,
        activeDrivers: 8,
        averageDeliveryTime: 28.5,
      );
    case 'week':
      return ReportData(
        period: 'Tuần này',
        totalOrders: 312,
        completedOrders: 298,
        totalRevenue: 8760000,
        totalDriverEarnings: 6132000,
        activeDrivers: 12,
        averageDeliveryTime: 32.1,
      );
    case 'month':
      return ReportData(
        period: 'Tháng này',
        totalOrders: 1245,
        completedOrders: 1189,
        totalRevenue: 35200000,
        totalDriverEarnings: 24640000,
        activeDrivers: 15,
        averageDeliveryTime: 29.8,
      );
    default:
      return ReportData(
        period: 'Hôm nay',
        totalOrders: 45,
        completedOrders: 42,
        totalRevenue: 1250000,
        totalDriverEarnings: 875000,
        activeDrivers: 8,
        averageDeliveryTime: 28.5,
      );
  }
});

class BaoCaoScreen extends ConsumerStatefulWidget {
  const BaoCaoScreen({super.key});

  @override
  ConsumerState<BaoCaoScreen> createState() => _BaoCaoScreenState();
}

class _BaoCaoScreenState extends ConsumerState<BaoCaoScreen> {
  String _selectedPeriod = 'today';
  
  final Map<String, String> _periods = {
    'today': 'Hôm nay',
    'week': 'Tuần này',
    'month': 'Tháng này',
  };

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(reportDataProvider(_selectedPeriod));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(reportDataProvider(_selectedPeriod)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          _buildPeriodSelector(),
          
          // Report content
          Expanded(
            child: reportAsync.when(
              data: (reportData) => _buildReportContent(context, reportData),
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
                      onPressed: () => ref.refresh(reportDataProvider(_selectedPeriod)),
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

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: _periods.entries.map((entry) {
          final isSelected = _selectedPeriod == entry.key;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXS),
              child: AppButton(
                text: entry.value,
                type: isSelected ? AppButtonType.primary : AppButtonType.outline,
                onPressed: () => setState(() => _selectedPeriod = entry.key),
                size: AppButtonSize.small,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, ReportData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview stats
          Text(
            'Tổng quan ${data.period.toLowerCase()}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          _buildStatsGrid(data),
          const SizedBox(height: AppTheme.spacingL),
          
          // Orders section
          _buildOrdersSection(data),
          const SizedBox(height: AppTheme.spacingL),
          
          // Revenue section
          _buildRevenueSection(data),
          const SizedBox(height: AppTheme.spacingL),
          
          // Drivers section
          _buildDriversSection(data),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ReportData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTheme.spacingM,
      mainAxisSpacing: AppTheme.spacingM,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Tổng đơn hàng',
          data.totalOrders.toString(),
          Icons.assignment,
          AppTheme.primaryColor,
        ),
        _buildStatCard(
          'Đơn hoàn thành',
          data.completedOrders.toString(),
          Icons.check_circle,
          AppTheme.successColor,
        ),
        _buildStatCard(
          'Doanh thu',
          AppFormatters.formatMoney(data.totalRevenue),
          Icons.monetization_on,
          AppTheme.warningColor,
        ),
        _buildStatCard(
          'Tài xế hoạt động',
          data.activeDrivers.toString(),
          Icons.people,
          AppTheme.infoColor,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection(ReportData data) {
    final completionRate = (data.completedOrders / data.totalOrders * 100);
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          _buildDetailRow('Tổng số đơn', data.totalOrders.toString()),
          _buildDetailRow('Đã hoàn thành', data.completedOrders.toString()),
          _buildDetailRow('Đang xử lý', (data.totalOrders - data.completedOrders).toString()),
          _buildDetailRow('Tỷ lệ hoàn thành', '${completionRate.toStringAsFixed(1)}%'),
          _buildDetailRow('Thời gian giao TB', '${data.averageDeliveryTime.toStringAsFixed(1)} phút'),
        ],
      ),
    );
  }

  Widget _buildRevenueSection(ReportData data) {
    final systemRevenue = data.totalRevenue - data.totalDriverEarnings;
    final systemRate = (systemRevenue / data.totalRevenue * 100);
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          _buildDetailRow('Tổng doanh thu', AppFormatters.formatMoney(data.totalRevenue)),
          _buildDetailRow('Thu nhập tài xế', AppFormatters.formatMoney(data.totalDriverEarnings)),
          _buildDetailRow('Doanh thu hệ thống', AppFormatters.formatMoney(systemRevenue)),
          _buildDetailRow('Tỷ lệ hệ thống', '${systemRate.toStringAsFixed(1)}%'),
          _buildDetailRow('DTB/đơn', AppFormatters.formatMoney(data.totalRevenue / data.totalOrders)),
        ],
      ),
    );
  }

  Widget _buildDriversSection(ReportData data) {
    final ordersPerDriver = (data.completedOrders / data.activeDrivers);
    final earningsPerDriver = (data.totalDriverEarnings / data.activeDrivers);
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tài xế',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AppButton(
                text: 'Chi tiết',
                size: AppButtonSize.small,
                type: AppButtonType.outline,
                onPressed: () => _showDriverDetails(context),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          _buildDetailRow('Tài xế hoạt động', data.activeDrivers.toString()),
          _buildDetailRow('Đơn/tài xế (TB)', ordersPerDriver.toStringAsFixed(1)),
          _buildDetailRow('Thu nhập/tài xế (TB)', AppFormatters.formatMoney(earningsPerDriver)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showDriverDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: const Column(
          children: [
            Text(
              'Chi tiết hiệu suất tài xế',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingL),
            Expanded(
              child: Center(
                child: Text(
                  'Tính năng chi tiết hiệu suất tài xế đang được phát triển...',
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
}

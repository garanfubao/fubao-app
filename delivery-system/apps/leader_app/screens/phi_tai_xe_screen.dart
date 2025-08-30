import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

class FeeRule {
  final String id;
  final String name;
  final double baseAmount;
  final double percentage;
  final String description;
  final bool isActive;

  FeeRule({
    required this.id,
    required this.name,
    required this.baseAmount,
    required this.percentage,
    required this.description,
    required this.isActive,
  });
}

final feeRulesProvider = FutureProvider<List<FeeRule>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    FeeRule(
      id: '1',
      name: 'Phí giao hàng cơ bản',
      baseAmount: 15000,
      percentage: 80,
      description: 'Tài xế nhận 80% phí giao hàng cơ bản',
      isActive: true,
    ),
    FeeRule(
      id: '2',
      name: 'Bonus cuối tuần',
      baseAmount: 0,
      percentage: 20,
      description: 'Thêm 20% cho đơn hàng cuối tuần',
      isActive: true,
    ),
    FeeRule(
      id: '3',
      name: 'Phí giao xa',
      baseAmount: 5000,
      percentage: 100,
      description: 'Thêm 5k cho đơn hàng >5km',
      isActive: true,
    ),
  ];
});

class PhiTaiXeScreen extends ConsumerWidget {
  const PhiTaiXeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeRulesAsync = ref.watch(feeRulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phí tài xế'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddFeeRuleDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(feeRulesProvider),
          ),
        ],
      ),
      body: feeRulesAsync.when(
        data: (feeRules) => _buildFeeRulesList(context, feeRules),
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
                onPressed: () => ref.refresh(feeRulesProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeRulesList(BuildContext context, List<FeeRule> feeRules) {
    if (feeRules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.money_off, size: 64, color: AppTheme.textSecondaryColor),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Chưa có quy định phí nào',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: feeRules.length,
      itemBuilder: (context, index) => _buildFeeRuleCard(context, feeRules[index]),
    );
  }

  Widget _buildFeeRuleCard(BuildContext context, FeeRule feeRule) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: () => _showFeeRuleDetails(context, feeRule),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  feeRule.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                value: feeRule.isActive,
                onChanged: (value) => _toggleFeeRule(context, feeRule),
                activeThumbColor: AppTheme.successColor,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          Text(
            feeRule.description,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          Row(
            children: [
              if (feeRule.baseAmount > 0) ...[
                const Icon(Icons.attach_money, size: 16, color: AppTheme.successColor),
                const SizedBox(width: AppTheme.spacingXS),
                Text(
                  AppFormatters.formatMoney(feeRule.baseAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
              ],
              const Icon(Icons.percent, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                '${feeRule.percentage.toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFeeRuleDetails(BuildContext context, FeeRule feeRule) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feeRule.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            Text(feeRule.description),
            const SizedBox(height: AppTheme.spacingM),
            
            if (feeRule.baseAmount > 0) ...[
              Text('Số tiền cố định: ${AppFormatters.formatMoney(feeRule.baseAmount)}'),
              const SizedBox(height: AppTheme.spacingS),
            ],
            Text('Tỷ lệ phần trăm: ${feeRule.percentage.toInt()}%'),
            const SizedBox(height: AppTheme.spacingL),
            
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Chỉnh sửa',
                    type: AppButtonType.outline,
                    onPressed: () => _editFeeRule(context, feeRule),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: AppButton(
                    text: feeRule.isActive ? 'Tắt' : 'Bật',
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleFeeRule(context, feeRule);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFeeRuleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm quy định phí mới'),
        content: const Text('Tính năng thêm quy định phí đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _editFeeRule(BuildContext context, FeeRule feeRule) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa: ${feeRule.name}'),
        content: const Text('Tính năng chỉnh sửa quy định phí đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _toggleFeeRule(BuildContext context, FeeRule feeRule) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          feeRule.isActive 
            ? 'Đã tắt quy định: ${feeRule.name}'
            : 'Đã bật quy định: ${feeRule.name}',
        ),
      ),
    );
  }
}

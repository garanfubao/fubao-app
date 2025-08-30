import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

class AreaPrice {
  final String id;
  final String areaName;
  final double basePrice;
  final double pricePerKm;
  final double rushHourMultiplier;
  final List<String> districts;
  final bool isActive;

  AreaPrice({
    required this.id,
    required this.areaName,
    required this.basePrice,
    required this.pricePerKm,
    required this.rushHourMultiplier,
    required this.districts,
    required this.isActive,
  });
}

final areaPricesProvider = FutureProvider<List<AreaPrice>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    AreaPrice(
      id: '1',
      areaName: 'Nội thành Hà Nội',
      basePrice: 15000,
      pricePerKm: 3000,
      rushHourMultiplier: 1.2,
      districts: ['Ba Đình', 'Hoàn Kiếm', 'Đống Đa', 'Hai Bà Trưng'],
      isActive: true,
    ),
    AreaPrice(
      id: '2',
      areaName: 'Ngoại thành Hà Nội',
      basePrice: 18000,
      pricePerKm: 4000,
      rushHourMultiplier: 1.3,
      districts: ['Cầu Giấy', 'Thanh Xuân', 'Hoàng Mai', 'Long Biên'],
      isActive: true,
    ),
    AreaPrice(
      id: '3',
      areaName: 'Vùng ven',
      basePrice: 25000,
      pricePerKm: 5000,
      rushHourMultiplier: 1.5,
      districts: ['Gia Lâm', 'Đông Anh', 'Sóc Sơn', 'Mê Linh'],
      isActive: false,
    ),
  ];
});

class GiaKhuVucScreen extends ConsumerWidget {
  const GiaKhuVucScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areaPricesAsync = ref.watch(areaPricesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giá theo khu vực'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAreaPriceDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(areaPricesProvider),
          ),
        ],
      ),
      body: areaPricesAsync.when(
        data: (areaPrices) => _buildAreaPricesList(context, areaPrices),
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
                onPressed: () => ref.refresh(areaPricesProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaPricesList(BuildContext context, List<AreaPrice> areaPrices) {
    if (areaPrices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: AppTheme.textSecondaryColor),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Chưa có bảng giá khu vực nào',
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
      itemCount: areaPrices.length,
      itemBuilder: (context, index) => _buildAreaPriceCard(context, areaPrices[index]),
    );
  }

  Widget _buildAreaPriceCard(BuildContext context, AreaPrice areaPrice) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: () => _showAreaPriceDetails(context, areaPrice),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  areaPrice.areaName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: areaPrice.isActive 
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.textDisabledColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  areaPrice.isActive ? 'Hoạt động' : 'Tạm dừng',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: areaPrice.isActive ? AppTheme.successColor : AppTheme.textDisabledColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Districts
          Wrap(
            spacing: AppTheme.spacingS,
            runSpacing: AppTheme.spacingXS,
            children: areaPrice.districts.take(3).map((district) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingS,
                vertical: AppTheme.spacingXS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Text(
                district,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.primaryColor,
                ),
              ),
            )).toList()
              ..add(
                areaPrice.districts.length > 3
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: AppTheme.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        '+${areaPrice.districts.length - 3}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Pricing info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giá cơ bản',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    Text(
                      AppFormatters.formatMoney(areaPrice.basePrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giá/km',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    Text(
                      AppFormatters.formatMoney(areaPrice.pricePerKm),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giờ cao điểm',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    Text(
                      'x${areaPrice.rushHourMultiplier}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAreaPriceDetails(BuildContext context, AreaPrice areaPrice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
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
                areaPrice.areaName,
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
                    // Pricing details
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bảng giá',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          _buildPriceRow('Giá cơ bản', AppFormatters.formatMoney(areaPrice.basePrice)),
                          _buildPriceRow('Giá mỗi km', AppFormatters.formatMoney(areaPrice.pricePerKm)),
                          _buildPriceRow('Hệ số giờ cao điểm', 'x${areaPrice.rushHourMultiplier}'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingM),
                    
                    // Districts
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Các quận/huyện áp dụng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Wrap(
                            spacing: AppTheme.spacingS,
                            runSpacing: AppTheme.spacingS,
                            children: areaPrice.districts.map((district) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                                vertical: AppTheme.spacingS,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                              ),
                              child: Text(
                                district,
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingM),
                    
                    // Example calculation
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ví dụ tính giá (5km, giờ thường)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          _buildPriceRow('Giá cơ bản', AppFormatters.formatMoney(areaPrice.basePrice)),
                          _buildPriceRow('Phí quãng đường (5km)', AppFormatters.formatMoney(areaPrice.pricePerKm * 5)),
                          const Divider(),
                          _buildPriceRow(
                            'Tổng cộng', 
                            AppFormatters.formatMoney(areaPrice.basePrice + (areaPrice.pricePerKm * 5)),
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Chỉnh sửa',
                      type: AppButtonType.outline,
                      onPressed: () => _editAreaPrice(context, areaPrice),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: AppButton(
                      text: areaPrice.isActive ? 'Tạm dừng' : 'Kích hoạt',
                      onPressed: () => _toggleAreaPrice(context, areaPrice),
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

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
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
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAreaPriceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm bảng giá khu vực mới'),
        content: const Text('Tính năng thêm bảng giá khu vực đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _editAreaPrice(BuildContext context, AreaPrice areaPrice) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa: ${areaPrice.areaName}'),
        content: const Text('Tính năng chỉnh sửa bảng giá khu vực đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _toggleAreaPrice(BuildContext context, AreaPrice areaPrice) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          areaPrice.isActive 
            ? 'Đã tạm dừng bảng giá: ${areaPrice.areaName}'
            : 'Đã kích hoạt bảng giá: ${areaPrice.areaName}',
        ),
      ),
    );
  }
}

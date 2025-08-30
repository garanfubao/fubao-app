import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/index.dart';
import '../../../common/utils/index.dart';

class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isImportant;
  final String type; // 'system', 'promotion', 'policy'

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isImportant = false,
    required this.type,
  });
}

final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  // Mock announcements data
  await Future.delayed(const Duration(milliseconds: 500));
  
  return [
    Announcement(
      id: '1',
      title: 'Cập nhật chính sách hoa hồng mới',
      content: 'Từ ngày 1/9, hoa hồng giao hàng tăng lên 85% phí giao hàng. Chi tiết xem tại mục Cài đặt > Chính sách.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isImportant: true,
      type: 'policy',
    ),
    Announcement(
      id: '2',
      title: 'Khuyến mãi cuối tuần',
      content: 'Tăng 20% hoa hồng cho tất cả đơn hàng vào cuối tuần (T7-CN). Cơ hội tăng thu nhập!',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isImportant: false,
      type: 'promotion',
    ),
    Announcement(
      id: '3',
      title: 'Bảo trì hệ thống',
      content: 'Hệ thống sẽ bảo trì từ 2:00-4:00 sáng ngày mai. Trong thời gian này, app có thể hoạt động chậm.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isImportant: false,
      type: 'system',
    ),
    Announcement(
      id: '4',
      title: 'Chương trình tài xế xuất sắc tháng 8',
      content: 'Chúc mừng top 10 tài xế xuất sắc tháng 8! Phần thưởng sẽ được cộng vào ví trong 3 ngày tới.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isImportant: false,
      type: 'system',
    ),
    Announcement(
      id: '5',
      title: 'Hướng dẫn sử dụng tính năng mới',
      content: 'App đã cập nhật tính năng theo dõi đơn hàng realtime. Xem hướng dẫn chi tiết tại mục Trợ giúp.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isImportant: false,
      type: 'system',
    ),
  ];
});

class BangTinScreen extends ConsumerWidget {
  const BangTinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng tin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(announcementsProvider),
          ),
        ],
      ),
      body: announcementsAsync.when(
        data: (announcements) => _buildAnnouncementsList(context, announcements),
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
                onPressed: () => ref.refresh(announcementsProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsList(BuildContext context, List<Announcement> announcements) {
    if (announcements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.announcement, size: 64, color: AppTheme.textSecondaryColor),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Chưa có thông báo nào',
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
      itemCount: announcements.length,
      itemBuilder: (context, index) => _buildAnnouncementCard(context, announcements[index]),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, Announcement announcement) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: () => _showAnnouncementDetails(context, announcement),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getTypeIcon(announcement.type),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  announcement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: announcement.isImportant 
                      ? AppTheme.errorColor 
                      : AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              if (announcement.isImportant)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: const Text(
                    'Quan trọng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          Text(
            announcement.content,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                AppFormatters.formatRelativeTime(announcement.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const Spacer(),
              Text(
                _getTypeText(announcement.type),
                style: TextStyle(
                  fontSize: 12,
                  color: _getTypeColor(announcement.type),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getTypeIcon(String type) {
    switch (type) {
      case 'system':
        return const Icon(Icons.settings, size: 20, color: AppTheme.primaryColor);
      case 'promotion':
        return const Icon(Icons.local_offer, size: 20, color: AppTheme.warningColor);
      case 'policy':
        return const Icon(Icons.policy, size: 20, color: AppTheme.errorColor);
      default:
        return const Icon(Icons.announcement, size: 20, color: AppTheme.textSecondaryColor);
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'system':
        return 'Hệ thống';
      case 'promotion':
        return 'Khuyến mãi';
      case 'policy':
        return 'Chính sách';
      default:
        return 'Thông báo';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'system':
        return AppTheme.primaryColor;
      case 'promotion':
        return AppTheme.warningColor;
      case 'policy':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  void _showAnnouncementDetails(BuildContext context, Announcement announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
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
              
              Row(
                children: [
                  _getTypeIcon(announcement.type),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: announcement.isImportant 
                          ? AppTheme.errorColor 
                          : AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              
              Row(
                children: [
                  Text(
                    _getTypeText(announcement.type),
                    style: TextStyle(
                      color: _getTypeColor(announcement.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Text(
                    AppFormatters.formatDateTime(announcement.createdAt),
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  if (announcement.isImportant) ...[
                    const SizedBox(width: AppTheme.spacingM),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: AppTheme.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: const Text(
                        'Quan trọng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    announcement.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Delivery System';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.delivery.com';
  static const String apiVersion = '/api/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // WebSocket Configuration
  static const String wsUrl = 'wss://ws.delivery.com';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  
  // Order Configuration
  static const double defaultDeliveryFee = 15000;
  static const double taxRate = 0.1; // 10%
  static const Duration orderTimeout = Duration(minutes: 30);
  
  // Driver Configuration
  static const double maxDeliveryDistance = 10.0; // km
  static const Duration locationUpdateInterval = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryDarkColor = Color(0xFF1976D2);
  static const Color primaryLightColor = Color(0xFFBBDEFB);
  
  // Accent Colors
  static const Color accentColor = Color(0xFFFF5722);
  static const Color accentDarkColor = Color(0xFFD84315);
  static const Color accentLightColor = Color(0xFFFFCCBC);
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textDisabledColor = Color(0xFFBDBDBD);
  
  // Order Status Colors
  static const Map<String, Color> orderStatusColors = {
    'created': Color(0xFF9E9E9E),
    'confirmed': Color(0xFF2196F3),
    'pooled': Color(0xFFFF9800),
    'assigned': Color(0xFF3F51B5),
    'pickedUp': Color(0xFF9C27B0),
    'delivered': Color(0xFF4CAF50),
    'cancelled': Color(0xFFF44336),
  };
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  // Elevation
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
}

class AppStrings {
  // Common
  static const String ok = 'OK';
  static const String cancel = 'Hủy';
  static const String save = 'Lưu';
  static const String delete = 'Xóa';
  static const String edit = 'Sửa';
  static const String add = 'Thêm';
  static const String loading = 'Đang tải...';
  static const String error = 'Lỗi';
  static const String success = 'Thành công';
  static const String noData = 'Không có dữ liệu';
  static const String retry = 'Thử lại';
  
  // Authentication
  static const String login = 'Đăng nhập';
  static const String logout = 'Đăng xuất';
  static const String email = 'Email';
  static const String password = 'Mật khẩu';
  static const String loginFailed = 'Đăng nhập thất bại';
  
  // Order Status
  static const String orderCreated = 'Đơn mới';
  static const String orderConfirmed = 'Đã xác nhận';
  static const String orderPooled = 'Chờ tài xế';
  static const String orderAssigned = 'Đã gán tài xế';
  static const String orderPickedUp = 'Đã lấy hàng';
  static const String orderDelivered = 'Đã giao';
  static const String orderCancelled = 'Đã hủy';
  
  // User Roles
  static const String admin = 'Quản trị viên';
  static const String leader = 'Trưởng nhóm';
  static const String driver = 'Tài xế';
  static const String restaurant = 'Quán ăn';
  
  // Navigation
  static const String dashboard = 'Tổng quan';
  static const String orders = 'Đơn hàng';
  static const String drivers = 'Tài xế';
  static const String restaurants = 'Quán ăn';
  static const String reports = 'Báo cáo';
  static const String settings = 'Cài đặt';
  static const String profile = 'Hồ sơ';
  static const String wallet = 'Ví tiền';
  
  // Error Messages
  static const String networkError = 'Lỗi kết nối mạng';
  static const String serverError = 'Lỗi máy chủ';
  static const String unknownError = 'Lỗi không xác định';
  static const String validationError = 'Dữ liệu không hợp lệ';
}

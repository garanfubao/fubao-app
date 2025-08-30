import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/utils/index.dart';
import '../../common/services/index.dart';
import 'screens/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize mock data
  ApiService().initializeMockData();
  
  runApp(const ProviderScope(child: DriverApp()));
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver App - ${AppConstants.appName}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppTheme.primaryColor,
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: AppTheme.elevation2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: AppTheme.cardColor,
          elevation: AppTheme.elevation2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingM,
          ),
        ),
      ),
      home: const DriverMainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DriverMainScreen extends ConsumerStatefulWidget {
  const DriverMainScreen({super.key});

  @override
  ConsumerState<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends ConsumerState<DriverMainScreen> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;

  final List<Widget> _screens = const [
    DonMoiScreen(),
    DangGiaoScreen(),
    HoanTatScreen(),
    BangTinScreen(),
    MenuScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.assignment),
      label: 'Đơn mới',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.delivery_dining),
      label: 'Đang giao',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.check_circle),
      label: 'Hoàn tất',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.announcement),
      label: 'Bảng tin',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: 'Menu',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    
    if (!isLoggedIn) {
      // Auto login as driver for demo
      await authService.loginWithRole(UserRole.driver);
    }
    
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
      ),
    );
  }
}

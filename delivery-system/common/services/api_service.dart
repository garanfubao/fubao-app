import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/index.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _uuid = const Uuid();

  // Mock data
  final List<User> _users = [];
  final List<Order> _orders = [];
  final List<Wallet> _wallets = [];
  final List<Transaction> _transactions = [];

  // Initialize with mock data
  void initializeMockData() {
    _initializeUsers();
    _initializeOrders();
    _initializeWallets();
    _initializeTransactions();
  }

  void _initializeUsers() {
    final now = DateTime.now();
    
    // Admin user
    _users.add(User(
      id: 'admin_001',
      name: 'Quản trị viên',
      email: 'admin@delivery.com',
      phone: '0123456789',
      role: UserRole.admin,
      status: UserStatus.active,
      createdAt: now,
      updatedAt: now,
    ));

    // Leader users
    _users.add(User(
      id: 'leader_001',
      name: 'Trưởng nhóm Hà Nội',
      email: 'leader.hn@delivery.com',
      phone: '0987654321',
      role: UserRole.leader,
      status: UserStatus.active,
      areaCode: 'HN',
      managedDrivers: const ['driver_001', 'driver_002'],
      createdAt: now,
      updatedAt: now,
    ));

    // Driver users
    _users.add(User(
      id: 'driver_001',
      name: 'Nguyễn Văn A',
      email: 'driver1@delivery.com',
      phone: '0901234567',
      role: UserRole.driver,
      status: UserStatus.active,
      vehicleType: 'Xe máy',
      vehicleNumber: '29A-12345',
      driverLicense: 'A1',
      createdAt: now,
      updatedAt: now,
    ));

    _users.add(User(
      id: 'driver_002',
      name: 'Trần Thị B',
      email: 'driver2@delivery.com',
      phone: '0902345678',
      role: UserRole.driver,
      status: UserStatus.active,
      vehicleType: 'Xe máy',
      vehicleNumber: '30B-67890',
      driverLicense: 'A1',
      createdAt: now,
      updatedAt: now,
    ));

    // Restaurant users
    _users.add(User(
      id: 'restaurant_001',
      name: 'Phở Hà Nội',
      email: 'pho.hanoi@delivery.com',
      phone: '0903456789',
      role: UserRole.restaurant,
      status: UserStatus.active,
      restaurantName: 'Phở Hà Nội',
      restaurantAddress: '123 Láng Hạ, Ba Đình, Hà Nội',
      businessLicense: 'BL001',
      createdAt: now,
      updatedAt: now,
    ));

    _users.add(User(
      id: 'restaurant_002',
      name: 'Cơm Tấm Sài Gòn',
      email: 'comtam.sg@delivery.com',
      phone: '0904567890',
      role: UserRole.restaurant,
      status: UserStatus.active,
      restaurantName: 'Cơm Tấm Sài Gòn',
      restaurantAddress: '456 Cầu Giấy, Cầu Giấy, Hà Nội',
      businessLicense: 'BL002',
      createdAt: now,
      updatedAt: now,
    ));
  }

  void _initializeOrders() {
    final now = DateTime.now();
    final random = Random();

    for (int i = 1; i <= 10; i++) {
      final orderId = 'order_${i.toString().padLeft(3, '0')}';
      final restaurantId = random.nextBool() ? 'restaurant_001' : 'restaurant_002';
      final restaurant = _users.firstWhere((u) => u.id == restaurantId);
      
      final items = [
        OrderItem(
          id: 'item_001',
          name: restaurantId == 'restaurant_001' ? 'Phở Bò' : 'Cơm Tấm Sườn',
          quantity: 1,
          price: 45000,
        ),
        const OrderItem(
          id: 'item_002',
          name: 'Nước ngọt',
          quantity: 2,
          price: 15000,
        ),
      ];

      final itemsTotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
      const deliveryFee = 15000.0;
      final tax = itemsTotal * 0.1;
      final total = itemsTotal + deliveryFee + tax;

      final status = OrderStatus.values[random.nextInt(OrderStatus.values.length)];
      final driverId = status.index >= OrderStatus.assigned.index ? 'driver_001' : null;

      _orders.add(Order(
        id: orderId,
        customerId: 'customer_$i',
        customerName: 'Khách hàng $i',
        customerPhone: '090000000$i',
        restaurantId: restaurantId,
        restaurantName: restaurant.restaurantName!,
        driverId: driverId,
        driverName: driverId != null ? 'Nguyễn Văn A' : null,
        items: items,
        restaurantAddress: Address(
          address: restaurant.restaurantAddress!,
          latitude: 21.0285 + random.nextDouble() * 0.1,
          longitude: 105.8542 + random.nextDouble() * 0.1,
        ),
        deliveryAddress: Address(
          address: 'Địa chỉ giao hàng $i',
          latitude: 21.0285 + random.nextDouble() * 0.1,
          longitude: 105.8542 + random.nextDouble() * 0.1,
        ),
        status: status,
        paymentMethod: PaymentMethod.values[random.nextInt(PaymentMethod.values.length)],
        paymentStatus: PaymentStatus.pending,
        itemsTotal: itemsTotal,
        deliveryFee: deliveryFee,
        tax: tax,
        discount: 0,
        total: total,
        note: 'Ghi chú đơn hàng $i',
        createdAt: now.subtract(Duration(hours: random.nextInt(24))),
        updatedAt: now,
        confirmedAt: status.index >= OrderStatus.confirmed.index ? now.subtract(Duration(minutes: random.nextInt(30))) : null,
        assignedAt: status.index >= OrderStatus.assigned.index ? now.subtract(Duration(minutes: random.nextInt(20))) : null,
        pickedUpAt: status.index >= OrderStatus.pickedUp.index ? now.subtract(Duration(minutes: random.nextInt(10))) : null,
        deliveredAt: status == OrderStatus.delivered ? now : null,
      ));
    }
  }

  void _initializeWallets() {
    final now = DateTime.now();
    
    for (final user in _users) {
      if (user.role == UserRole.driver || user.role == UserRole.restaurant) {
        _wallets.add(Wallet(
          id: _uuid.v4(),
          userId: user.id,
          balance: Random().nextDouble() * 1000000,
          totalEarnings: Random().nextDouble() * 5000000,
          totalWithdrawals: Random().nextDouble() * 2000000,
          createdAt: now,
          updatedAt: now,
        ));
      }
    }
  }

  void _initializeTransactions() {
    final now = DateTime.now();
    final random = Random();

    for (final wallet in _wallets) {
      for (int i = 0; i < 5; i++) {
        final amount = random.nextDouble() * 100000;
        _transactions.add(Transaction(
          id: _uuid.v4(),
          userId: wallet.userId,
          orderId: random.nextBool() ? _orders[random.nextInt(_orders.length)].id : null,
          type: TransactionType.values[random.nextInt(TransactionType.values.length)],
          amount: amount,
          balanceBefore: wallet.balance - amount,
          balanceAfter: wallet.balance,
          status: TransactionStatus.completed,
          description: 'Giao dịch mẫu',
          createdAt: now.subtract(Duration(days: random.nextInt(30))),
          updatedAt: now,
        ));
      }
    }
  }

  // User API methods
  Future<List<User>> getUsers({UserRole? role}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    if (role != null) {
      return _users.where((user) => user.role == role).toList();
    }
    return List.from(_users);
  }

  Future<User?> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Order API methods
  Future<List<Order>> getOrders({OrderStatus? status, String? driverId, String? restaurantId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var filteredOrders = List<Order>.from(_orders);
    
    if (status != null) {
      filteredOrders = filteredOrders.where((order) => order.status == status).toList();
    }
    if (driverId != null) {
      filteredOrders = filteredOrders.where((order) => order.driverId == driverId).toList();
    }
    if (restaurantId != null) {
      filteredOrders = filteredOrders.where((order) => order.restaurantId == restaurantId).toList();
    }
    
    return filteredOrders;
  }

  Future<Order?> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Order> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final now = DateTime.now();
      Order updatedOrder = _orders[orderIndex].copyWith(
        status: newStatus,
        updatedAt: now,
      );

      // Update specific timestamps based on status
      switch (newStatus) {
        case OrderStatus.confirmed:
          updatedOrder = updatedOrder.copyWith(confirmedAt: now);
          break;
        case OrderStatus.assigned:
          updatedOrder = updatedOrder.copyWith(assignedAt: now);
          break;
        case OrderStatus.pickedUp:
          updatedOrder = updatedOrder.copyWith(pickedUpAt: now);
          break;
        case OrderStatus.delivered:
          updatedOrder = updatedOrder.copyWith(deliveredAt: now);
          break;
        case OrderStatus.cancelled:
          updatedOrder = updatedOrder.copyWith(cancelledAt: now);
          break;
        default:
          break;
      }

      _orders[orderIndex] = updatedOrder;
      return updatedOrder;
    }
    throw Exception('Order not found');
  }

  Future<Order> assignDriverToOrder(String orderId, String driverId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    final driver = await getUserById(driverId);
    
    if (orderIndex != -1 && driver != null) {
      final updatedOrder = _orders[orderIndex].copyWith(
        driverId: driverId,
        driverName: driver.name,
        status: OrderStatus.assigned,
        assignedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _orders[orderIndex] = updatedOrder;
      return updatedOrder;
    }
    throw Exception('Order or driver not found');
  }

  // Wallet API methods
  Future<Wallet?> getWalletByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _wallets.firstWhere((wallet) => wallet.userId == userId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Transaction>> getTransactionsByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _transactions.where((transaction) => transaction.userId == userId).toList();
  }

  Future<Transaction> createTransaction(
    String userId,
    TransactionType type,
    double amount,
    String description, {
    String? orderId,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final wallet = await getWalletByUserId(userId);
    if (wallet == null) throw Exception('Wallet not found');

    final transaction = Transaction(
      id: _uuid.v4(),
      userId: userId,
      orderId: orderId,
      type: type,
      amount: amount,
      balanceBefore: wallet.balance,
      balanceAfter: wallet.balance + (type == TransactionType.deposit || type == TransactionType.commission ? amount : -amount),
      status: TransactionStatus.completed,
      description: description,
      note: note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _transactions.add(transaction);
    
    // Update wallet balance
    final walletIndex = _wallets.indexWhere((w) => w.userId == userId);
    if (walletIndex != -1) {
      _wallets[walletIndex] = wallet.copyWith(
        balance: transaction.balanceAfter,
        updatedAt: DateTime.now(),
      );
    }

    return transaction;
  }
}

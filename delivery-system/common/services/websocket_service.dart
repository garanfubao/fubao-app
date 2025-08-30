import 'dart:async';
import 'dart:math';
import '../models/index.dart';

enum WebSocketEventType {
  orderCreated,
  orderUpdated,
  orderAssigned,
  orderStatusChanged,
  driverLocationUpdated,
  newMessage,
}

class WebSocketEvent {
  final WebSocketEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WebSocketEvent({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final StreamController<WebSocketEvent> _eventController = StreamController<WebSocketEvent>.broadcast();
  Stream<WebSocketEvent> get events => _eventController.stream;

  Timer? _mockTimer;
  bool _isConnected = false;

  Future<void> connect(String userId) async {
    if (_isConnected) return;

    // Simulate connection delay
    await Future.delayed(const Duration(milliseconds: 500));
    _isConnected = true;

    // Start mock events
    _startMockEvents();
  }

  void disconnect() {
    _isConnected = false;
    _mockTimer?.cancel();
    _mockTimer = null;
  }

  void _startMockEvents() {
    _mockTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      // Generate random mock events
      final random = Random();
      const eventTypes = WebSocketEventType.values;
      final randomEventType = eventTypes[random.nextInt(eventTypes.length)];

      Map<String, dynamic> data = {};

      switch (randomEventType) {
        case WebSocketEventType.orderCreated:
          data = {
            'orderId': 'order_${random.nextInt(1000)}',
            'restaurantId': 'restaurant_${random.nextInt(3) + 1}',
            'customerName': 'Khách hàng ${random.nextInt(100)}',
            'total': random.nextDouble() * 200000 + 50000,
          };
          break;

        case WebSocketEventType.orderUpdated:
          data = {
            'orderId': 'order_${random.nextInt(10) + 1}',
            'status': OrderStatus.values[random.nextInt(OrderStatus.values.length)].name,
            'updatedAt': DateTime.now().toIso8601String(),
          };
          break;

        case WebSocketEventType.orderAssigned:
          data = {
            'orderId': 'order_${random.nextInt(10) + 1}',
            'driverId': 'driver_${random.nextInt(5) + 1}',
            'driverName': 'Tài xế ${random.nextInt(10) + 1}',
            'estimatedPickupTime': DateTime.now().add(Duration(minutes: 15 + random.nextInt(15))).toIso8601String(),
          };
          break;

        case WebSocketEventType.driverLocationUpdated:
          data = {
            'driverId': 'driver_${random.nextInt(5) + 1}',
            'latitude': 21.0285 + random.nextDouble() * 0.1,
            'longitude': 105.8542 + random.nextDouble() * 0.1,
            'heading': random.nextDouble() * 360,
            'speed': random.nextDouble() * 60,
          };
          break;

        case WebSocketEventType.orderStatusChanged:
          data = {
            'orderId': 'order_${random.nextInt(10) + 1}',
            'oldStatus': OrderStatus.values[random.nextInt(OrderStatus.values.length)].name,
            'newStatus': OrderStatus.values[random.nextInt(OrderStatus.values.length)].name,
            'changedAt': DateTime.now().toIso8601String(),
          };
          break;

        case WebSocketEventType.newMessage:
          data = {
            'messageId': 'msg_${random.nextInt(1000)}',
            'fromUserId': 'user_${random.nextInt(10) + 1}',
            'toUserId': 'user_${random.nextInt(10) + 1}',
            'content': 'Tin nhắn mẫu ${random.nextInt(100)}',
            'timestamp': DateTime.now().toIso8601String(),
          };
          break;
      }

      _eventController.add(WebSocketEvent(
        type: randomEventType,
        data: data,
      ));
    });
  }

  // Send mock events
  void sendOrderUpdate(String orderId, OrderStatus newStatus) {
    if (!_isConnected) return;

    _eventController.add(WebSocketEvent(
      type: WebSocketEventType.orderStatusChanged,
      data: {
        'orderId': orderId,
        'newStatus': newStatus.name,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ));
  }

  void sendDriverLocationUpdate(String driverId, double latitude, double longitude) {
    if (!_isConnected) return;

    _eventController.add(WebSocketEvent(
      type: WebSocketEventType.driverLocationUpdated,
      data: {
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }

  void sendMessage(String fromUserId, String toUserId, String content) {
    if (!_isConnected) return;

    _eventController.add(WebSocketEvent(
      type: WebSocketEventType.newMessage,
      data: {
        'messageId': 'msg_${DateTime.now().millisecondsSinceEpoch}',
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }

  // Stream filters for specific event types
  Stream<WebSocketEvent> get orderEvents => events.where((event) => [
        WebSocketEventType.orderCreated,
        WebSocketEventType.orderUpdated,
        WebSocketEventType.orderAssigned,
        WebSocketEventType.orderStatusChanged,
      ].contains(event.type));

  Stream<WebSocketEvent> get driverLocationEvents => events.where((event) => event.type == WebSocketEventType.driverLocationUpdated);

  Stream<WebSocketEvent> get messageEvents => events.where((event) => event.type == WebSocketEventType.newMessage);

  void dispose() {
    disconnect();
    _eventController.close();
  }
}

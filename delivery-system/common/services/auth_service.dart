import 'package:shared_preferences/shared_preferences.dart';
import '../models/index.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  User? get currentUser => _currentUser;

  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  Future<bool> login(String email, String password) async {
    try {
      final user = await _apiService.login(email, password);
      if (user != null) {
        _currentUser = user;
        await _saveUserSession(user);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginWithRole(UserRole role) async {
    try {
      // Mock login - get first user with specified role
      final users = await _apiService.getUsers(role: role);
      if (users.isNotEmpty) {
        _currentUser = users.first;
        await _saveUserSession(users.first);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _clearUserSession();
  }

  Future<bool> isLoggedIn() async {
    if (_currentUser != null) return true;
    
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    
    if (userId != null) {
      final user = await _apiService.getUserById(userId);
      if (user != null) {
        _currentUser = user;
        return true;
      }
    }
    
    return false;
  }

  Future<void> _saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userRoleKey, user.role.name);
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
  }

  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  bool hasAnyRole(List<UserRole> roles) {
    return _currentUser != null && roles.contains(_currentUser!.role);
  }
}

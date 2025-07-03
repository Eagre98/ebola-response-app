import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/localization_service.dart';

class AppProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  AppLanguage _currentLanguage = AppLanguage.english;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AppLanguage get currentLanguage => _currentLanguage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isMedicalTeam => _currentUser?.isMedicalTeam ?? false;
  bool get needsApproval => _currentUser?.needsApproval ?? false;

  // Initialize the provider
  Future<void> initialize() async {
    setLoading(true);
    try {
      // Listen to auth state changes
      _authService.authStateChanges.listen(_onAuthStateChanged);

      // Check if user is already logged in
      User? firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      }
    } catch (e) {
      setError('Failed to initialize app: $e');
    } finally {
      setLoading(false);
    }
  }

  // Handle auth state changes
  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _loadUserData(firebaseUser.uid);
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      UserModel? userData = await _authService.getUserData(uid);
      _currentUser = userData;
      notifyListeners();
    } catch (e) {
      setError('Failed to load user data: $e');
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    setLoading(true);
    clearError();

    try {
      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    UserRole role,
  ) async {
    setLoading(true);
    clearError();

    try {
      await _authService.registerWithEmailAndPassword(
        email,
        password,
        firstName,
        lastName,
        role,
      );
      return true;
    } catch (e) {
      setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    setLoading(true);
    clearError();

    try {
      await _authService.signInWithGoogle();
      return true;
    } catch (e) {
      setError('Google sign-in failed: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    setLoading(true);
    clearError();

    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      setError('Sign out failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // Update user role (admin only)
  Future<bool> updateUserRole(String uid, UserRole newRole) async {
    if (!isAdmin) return false;

    setLoading(true);
    clearError();

    try {
      await _authService.updateUserRole(uid, newRole);
      return true;
    } catch (e) {
      setError('Failed to update user role: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Approve user (admin only)
  Future<bool> approveUser(String uid) async {
    if (!isAdmin) return false;

    setLoading(true);
    clearError();

    try {
      await _authService.approveUser(uid);
      return true;
    } catch (e) {
      setError('Failed to approve user: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Change language
  void changeLanguage(AppLanguage language) {
    _currentLanguage = language;
    LocalizationService.setLanguage(language);
    notifyListeners();
  }

  // Refresh current user data
  Future<void> refreshUserData() async {
    if (_authService.currentUser != null) {
      await _loadUserData(_authService.currentUser!.uid);
    }
  }

  // Utility methods
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Navigation helpers
  String getHomeRoute() {
    if (_currentUser == null) return '/';

    if (_currentUser!.needsApproval) {
      return '/pending-approval';
    }

    if (_currentUser!.isAdmin) {
      return '/admin-dashboard';
    }

    if (_currentUser!.isMedicalTeam) {
      return '/medical-dashboard';
    }

    return '/user-dashboard';
  }

  // Check if user can access a route
  bool canAccessRoute(String route) {
    if (_currentUser == null) {
      return ['/', '/login', '/register', '/chat'].contains(route);
    }

    if (_currentUser!.needsApproval) {
      return ['/pending-approval', '/settings'].contains(route);
    }

    switch (route) {
      case '/admin-dashboard':
      case '/manage-users':
      case '/manage-alerts':
        return _currentUser!.isAdmin;
      case '/medical-dashboard':
      case '/create-alert':
      case '/my-alerts':
        return _currentUser!.isMedicalTeam;
      case '/user-dashboard':
      case '/settings':
      case '/chat':
        return true;
      default:
        return false;
    }
  }
}

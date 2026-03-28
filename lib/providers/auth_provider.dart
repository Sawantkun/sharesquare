import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/theme/app_colors.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  Future<void> _handleAuthStateChange(User? user) async {
    if (user == null) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromJson(doc.data()!);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromJson(doc.data()!);
        _status = AuthStatus.authenticated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);
      final user = UserModel(
        id: cred.user!.uid,
        name: name,
        email: email,
        color: AppColors.primary,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(user.id).set(user.toJson());
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Signup failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Password reset failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void updateProfile(UserModel updated) {
    _currentUser = updated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      notifyListeners();
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _friendlyError(e.code);
    }
  }

  Future<UserCredential?> register(
      String email, String password, String name, String village) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await cred.user?.updateDisplayName(name);
      // Store user profile
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'village': village,
        'createdAt': FieldValue.serverTimestamp(),
        'borewellCount': 0,
      });
      notifyListeners();
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _friendlyError(e.code);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

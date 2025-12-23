import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<String?> signUp({required String email, required String password,   required String username}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Save extra user details to Firestore
      await _db.collection('users').doc(result.user!.uid).set({
        'username': username,
        'email': email,
        'photoUrl': '', // Empty initially
        'createdAt': DateTime.now().toIso8601String(),
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign In
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Fetch User Profile Data
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;
    DocumentSnapshot doc = await _db.collection('users').doc(currentUser!.uid).get();
    return doc.data() as Map<String, dynamic>?;
  }
}
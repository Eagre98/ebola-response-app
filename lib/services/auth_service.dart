import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Sign in error: $e');
      throw e;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    UserRole role,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (result.user != null) {
        UserModel userModel = UserModel(
          uid: result.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: role == UserRole.medicalTeam ? UserRole.pendingApproval : role,
          createdAt: DateTime.now(),
          isApproved:
              role == UserRole.normalUser, // Normal users are auto-approved
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userModel.toMap());
      }

      return result;
    } catch (e) {
      print('Registration error: $e');
      throw e;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      // Check if user document exists, create if not
      if (result.user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(result.user!.uid).get();

        if (!userDoc.exists) {
          // Create new user document for Google sign-in
          UserModel userModel = UserModel(
            uid: result.user!.uid,
            email: result.user!.email ?? '',
            firstName: result.user!.displayName?.split(' ').first ?? '',
            lastName:
                result.user!.displayName?.split(' ').skip(1).join(' ') ?? '',
            role: UserRole.normalUser,
            createdAt: DateTime.now(),
            isApproved: true, // Google users are auto-approved as normal users
          );

          await _firestore
              .collection('users')
              .doc(result.user!.uid)
              .set(userModel.toMap());
        }
      }

      return result;
    } catch (e) {
      print('Google sign in error: $e');
      throw e;
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String uid, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole.toString().split('.').last,
        'isApproved': true,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': currentUser?.uid,
      });
    } catch (e) {
      print('Update user role error: $e');
      throw e;
    }
  }

  // Approve user (admin only)
  Future<void> approveUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isApproved': true,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': currentUser?.uid,
        'role': 'medicalTeam', // Convert from pendingApproval to medicalTeam
      });
    } catch (e) {
      print('Approve user error: $e');
      throw e;
    }
  }

  // Get all users (admin only)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Get pending approval users (admin only)
  Stream<List<UserModel>> getPendingApprovalUsers() {
    return _firestore
        .collection('users')
        .where('isApproved', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      throw e;
    }
  }
}

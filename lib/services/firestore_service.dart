import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alert_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create new alert
  Future<String> createAlert(AlertModel alert) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('alerts').add(alert.toMap());
      return docRef.id;
    } catch (e) {
      print('Create alert error: $e');
      throw e;
    }
  }

  // Get all alerts
  Stream<List<AlertModel>> getAllAlerts() {
    return _firestore
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get alerts by status
  Stream<List<AlertModel>> getAlertsByStatus(AlertStatus status) {
    return _firestore
        .collection('alerts')
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get alerts assigned to current user
  Stream<List<AlertModel>> getMyAssignedAlerts() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('alerts')
        .where('assignedTo', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get alerts created by current user
  Stream<List<AlertModel>> getMyCreatedAlerts() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('alerts')
        .where('createdBy', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Assign alert to medical team member (admin only)
  Future<void> assignAlert(String alertId, String assignedToUid) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'assignedTo': assignedToUid,
        'status': AlertStatus.assigned.toString().split('.').last,
        'assignedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Assign alert error: $e');
      throw e;
    }
  }

  // Update alert status
  Future<void> updateAlertStatus(String alertId, AlertStatus status,
      {String? notes}) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status.toString().split('.').last,
      };

      if (status == AlertStatus.closed) {
        updateData['closedAt'] = FieldValue.serverTimestamp();
        updateData['closedBy'] = _auth.currentUser?.uid;
        if (notes != null) {
          updateData['notes'] = notes;
        }
      } else if (status == AlertStatus.inProgress) {
        // No additional fields needed for in progress
      }

      await _firestore.collection('alerts').doc(alertId).update(updateData);
    } catch (e) {
      print('Update alert status error: $e');
      throw e;
    }
  }

  // Get alert statistics
  Future<Map<String, int>> getAlertStatistics() async {
    try {
      // Get counts for different statuses
      final totalQuery = await _firestore.collection('alerts').get();
      final openQuery = await _firestore
          .collection('alerts')
          .where('status', isEqualTo: 'open')
          .get();
      final assignedQuery = await _firestore
          .collection('alerts')
          .where('status', isEqualTo: 'assigned')
          .get();
      final inProgressQuery = await _firestore
          .collection('alerts')
          .where('status', isEqualTo: 'inProgress')
          .get();
      final closedQuery = await _firestore
          .collection('alerts')
          .where('status', isEqualTo: 'closed')
          .get();

      return {
        'total': totalQuery.docs.length,
        'open': openQuery.docs.length,
        'assigned': assignedQuery.docs.length,
        'inProgress': inProgressQuery.docs.length,
        'closed': closedQuery.docs.length,
      };
    } catch (e) {
      print('Get alert statistics error: $e');
      return {
        'total': 0,
        'open': 0,
        'assigned': 0,
        'inProgress': 0,
        'closed': 0,
      };
    }
  }

  // Get medical team members for assignment
  Future<List<UserModel>> getMedicalTeamMembers() async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('role', whereIn: ['medicalTeam', 'admin'])
          .where('isApproved', isEqualTo: true)
          .get();

      return query.docs
          .map((doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Get medical team members error: $e');
      return [];
    }
  }

  // Get user statistics (for admin dashboard)
  Future<Map<String, int>> getUserStatistics() async {
    try {
      final totalQuery = await _firestore.collection('users').get();
      final adminQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();
      final medicalQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'medicalTeam')
          .get();
      final pendingQuery = await _firestore
          .collection('users')
          .where('isApproved', isEqualTo: false)
          .get();

      return {
        'total': totalQuery.docs.length,
        'admin': adminQuery.docs.length,
        'medicalTeam': medicalQuery.docs.length,
        'pending': pendingQuery.docs.length,
      };
    } catch (e) {
      print('Get user statistics error: $e');
      return {
        'total': 0,
        'admin': 0,
        'medicalTeam': 0,
        'pending': 0,
      };
    }
  }

  // Delete alert (admin only)
  Future<void> deleteAlert(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).delete();
    } catch (e) {
      print('Delete alert error: $e');
      throw e;
    }
  }

  // Get single alert
  Future<AlertModel?> getAlert(String alertId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('alerts').doc(alertId).get();
      if (doc.exists) {
        return AlertModel.fromMap(doc.data() as Map<String, dynamic>, alertId);
      }
      return null;
    } catch (e) {
      print('Get alert error: $e');
      return null;
    }
  }
}

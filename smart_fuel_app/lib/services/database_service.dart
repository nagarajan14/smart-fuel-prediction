import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';
import '../models/fuel_log_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create User Document
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  // Get User Profile
  Future<UserModel?> getUser(String uid) async {
    var snap = await _db.collection('users').doc(uid).get();
    if (snap.exists) {
      return UserModel.fromMap(snap.data()!, snap.id);
    }
    return null;
  }

  // Add Vehicle
  Future<String> addVehicle(VehicleModel vehicle) async {
    var docRef = await _db.collection('vehicles').add(vehicle.toMap());
    return docRef.id;
  }

  // Get User's Vehicles (Stream)
  Stream<List<VehicleModel>> streamVehicles(String userId) {
    return _db
        .collection('vehicles')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream Real-time Fuel Logs for a specific vehicle
  Stream<List<FuelLogModel>> streamFuelLogs(String vehicleId) {
    return _db
        .collection('fuel_logs')
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FuelLogModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Helper method to add fake IoT data manually
  Future<void> addMockFuelLog(FuelLogModel log) async {
    await _db.collection('fuel_logs').add(log.toMap());
  }
}

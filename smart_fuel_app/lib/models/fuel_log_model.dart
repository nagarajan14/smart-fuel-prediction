import 'package:cloud_firestore/cloud_firestore.dart';

class FuelLogModel {
  final String id;
  final String vehicleId;
  final double fuelLevel;
  final double fuelPercentage;
  final double distanceCovered;
  final double fuelConsumed;
  final double speed;
  final String trafficCondition;
  final String drivingStyle;
  final DateTime timestamp;

  FuelLogModel({
    required this.id,
    required this.vehicleId,
    required this.fuelLevel,
    required this.fuelPercentage,
    this.distanceCovered = 0.0,
    this.fuelConsumed = 0.0,
    this.speed = 0.0,
    this.trafficCondition = 'Normal',
    this.drivingStyle = 'Normal',
    required this.timestamp,
  });

  factory FuelLogModel.fromMap(Map<String, dynamic> data, String documentId) {
    return FuelLogModel(
      id: documentId,
      vehicleId: data['vehicleId'] ?? '',
      fuelLevel: (data['fuelLevel'] ?? 0.0).toDouble(),
      fuelPercentage: (data['fuelPercentage'] ?? 0.0).toDouble(),
      distanceCovered: (data['distanceCovered'] ?? 0.0).toDouble(),
      fuelConsumed: (data['fuelConsumed'] ?? 0.0).toDouble(),
      speed: (data['speed'] ?? 0.0).toDouble(),
      trafficCondition: data['trafficCondition'] ?? 'Normal',
      drivingStyle: data['drivingStyle'] ?? 'Normal',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'fuelLevel': fuelLevel,
      'fuelPercentage': fuelPercentage,
      'distanceCovered': distanceCovered,
      'fuelConsumed': fuelConsumed,
      'speed': speed,
      'trafficCondition': trafficCondition,
      'drivingStyle': drivingStyle,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

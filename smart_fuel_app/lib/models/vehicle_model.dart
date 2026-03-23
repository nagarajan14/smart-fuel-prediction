class VehicleModel {
  final String id;
  final String userId;
  final String name;
  final String type; // bike, car, truck
  final double tankCapacity;
  final double averageMileage;

  VehicleModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.tankCapacity,
    required this.averageMileage,
  });

  factory VehicleModel.fromMap(Map<String, dynamic> data, String documentId) {
    return VehicleModel(
      id: documentId,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? 'car',
      tankCapacity: (data['tankCapacity'] ?? 0.0).toDouble(),
      averageMileage: (data['averageMileage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'tankCapacity': tankCapacity,
      'averageMileage': averageMileage,
    };
  }
}

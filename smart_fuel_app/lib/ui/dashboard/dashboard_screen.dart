import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/vehicle_model.dart';
import '../../models/fuel_log_model.dart';
import '../vehicle/add_vehicle_screen.dart';
import '../maps/nearby_stations_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  VehicleModel? _selectedVehicle;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final dbService = Provider.of<DatabaseService>(context);
    final userId = authService.currentUserId;

    if (userId == null) return const Scaffold(body: Center(child: Text("Not logged in")));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.map), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyStationsScreen()));
          }),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => authService.signOut()),
        ],
      ),
      body: StreamBuilder<List<VehicleModel>>(
        stream: dbService.streamVehicles(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final vehicles = snapshot.data ?? [];
          
          if (vehicles.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehicleScreen())),
                child: const Text('Add your first vehicle'),
              ),
            );
          }

          _selectedVehicle ??= vehicles.first;

          return _buildDashboardContent(dbService, _selectedVehicle!);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehicleScreen())),
      ),
    );
  }

  Widget _buildDashboardContent(DatabaseService db, VehicleModel vehicle) {
    return StreamBuilder<List<FuelLogModel>>(
      stream: db.streamFuelLogs(vehicle.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final logs = snapshot.data!;
        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Waiting for ESP32 Data...'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Inject fake data for testing
                    db.addMockFuelLog(FuelLogModel(
                      id: '',
                      vehicleId: vehicle.id,
                      fuelLevel: vehicle.tankCapacity * 0.8,
                      fuelPercentage: 80.0,
                      distanceCovered: 24.5,
                      fuelConsumed: 2.1,
                      speed: 65.0,
                      trafficCondition: 'Moderate',
                      drivingStyle: 'Eco',
                      timestamp: DateTime.now(),
                    ));
                  },
                  child: const Text('Simulate Data Pushed'),
                )
              ],
            ),
          );
        }

        final currentLog = logs.first;
        final predDistance = _calculateDynamicPrediction(logs, vehicle);

        // Check for sudden drop alerts
        if (logs.length > 1) {
          final previousLog = logs[1];
          // E.g., drops more than 10% in short time -> theft alert
          if ((previousLog.fuelPercentage - currentLog.fuelPercentage) > 10.0 && 
              currentLog.timestamp.difference(previousLog.timestamp).inMinutes < 5) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ALERT! Sudden fuel drop detected. Possible theft!'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            });
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Vehicle: \${vehicle.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildFuelIndicator(currentLog),
              const SizedBox(height: 20),
              _buildPredictions(predDistance, currentLog.fuelLevel, currentLog),
              const SizedBox(height: 30),
              const Text('Fuel Usage History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildHistoryChart(logs),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFuelIndicator(FuelLogModel log) {
    Color ringColor = Color(0xFF00FF7F);
    if (log.fuelPercentage < 20) ringColor = Colors.redAccent;
    else if (log.fuelPercentage < 50) ringColor = Colors.orangeAccent;

    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor, width: 8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\${log.fuelPercentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: ringColor)),
              const Text('Fuel Remaining', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictions(double distance, double fuelLeft, FuelLogModel currentLog) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.route, color: Colors.blueAccent, size: 30),
                    const SizedBox(height: 8),
                    Text('\${distance.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('Est. Distance', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.lightBlue, size: 30),
                    const SizedBox(height: 8),
                    Text('\${fuelLeft.toStringAsFixed(1)} L', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('Liters Left', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
            const Divider(height: 30, color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFactorChip(Icons.traffic, currentLog.trafficCondition),
                _buildFactorChip(Icons.speed, '\${currentLog.speed.toStringAsFixed(0)} km/h'),
                _buildFactorChip(Icons.person, currentLog.drivingStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  double _calculateDynamicPrediction(List<FuelLogModel> logs, VehicleModel vehicle) {
    if (logs.isEmpty) return 0.0;
    
    final currentLog = logs.first;
    double baseEfficiency = vehicle.averageMileage;

    // 1. Calculate historical efficiency if we have enough data
    double totalDistance = 0;
    double totalConsumed = 0;
    
    // Use up to the last 10 logs for recent history
    final recentLogs = logs.take(10).toList();
    for (var log in recentLogs) {
      if (log.distanceCovered > 0 && log.fuelConsumed > 0) {
        totalDistance += log.distanceCovered;
        totalConsumed += log.fuelConsumed;
      }
    }

    if (totalConsumed > 0) {
      baseEfficiency = totalDistance / totalConsumed; // dynamic historical efficiency
    }

    // 2. Apply contextual modifiers
    double modifier = 1.0;

    // Traffic Condition
    if (currentLog.trafficCondition == 'Heavy') modifier -= 0.15;
    else if (currentLog.trafficCondition == 'Moderate') modifier -= 0.05;
    else if (currentLog.trafficCondition == 'Light') modifier += 0.05;

    // Driving Style
    if (currentLog.drivingStyle == 'Aggressive') modifier -= 0.10;
    else if (currentLog.drivingStyle == 'Eco') modifier += 0.10;

    // Speed bonus/penalty (Assuming optimal is 60-80 km/h)
    if (currentLog.speed > 0) {
      if (currentLog.speed < 20 || currentLog.speed > 110) modifier -= 0.05;
      else if (currentLog.speed >= 60 && currentLog.speed <= 80) modifier += 0.05;
    }

    double finalEfficiency = baseEfficiency * modifier;
    if (finalEfficiency <= 0) finalEfficiency = 1.0; // fallback

    return currentLog.fuelLevel * finalEfficiency;
  }

  Widget _buildHistoryChart(List<FuelLogModel> logs) {
    // Take up to last 10 logs and reverse them for chronological order on X-axis
    final chartLogs = logs.take(10).toList().reversed.toList();

    List<FlSpot> spots = [];
    for (int i = 0; i < chartLogs.length; i++) {
      spots.add(FlSpot(i.toDouble(), chartLogs[i].fuelPercentage));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (chartLogs.length - 1).toDouble().clamp(0, double.infinity),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: const Color(0xFF00FF7F),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: const Color(0xFF00FF7F).withOpacity(0.2)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

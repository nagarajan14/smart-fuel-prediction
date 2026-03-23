import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle_model.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({Key? key}) : super(key: key);

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _mileageController = TextEditingController();
  String _selectedType = 'car';
  bool _isLoading = false;

  void _saveVehicle() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final userId = authService.currentUserId;

    if (userId == null) return;

    setState(() => _isLoading = true);

    VehicleModel vehicle = VehicleModel(
      id: '',
      userId: userId,
      name: _nameController.text.trim(),
      type: _selectedType,
      tankCapacity: double.tryParse(_capacityController.text.trim()) ?? 0.0,
      averageMileage: double.tryParse(_mileageController.text.trim()) ?? 0.0,
    );

    await dbService.addVehicle(vehicle);

    setState(() => _isLoading = false);
    if(mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Vehicle Name (e.g., Honda Civic)'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Vehicle Type'),
              items: const [
                DropdownMenuItem(value: 'bike', child: Text('Bike')),
                DropdownMenuItem(value: 'car', child: Text('Car')),
                DropdownMenuItem(value: 'truck', child: Text('Truck')),
              ],
              onChanged: (val) {
                setState(() => _selectedType = val!);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _capacityController,
              decoration: const InputDecoration(labelText: 'Tank Capacity (Liters)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mileageController,
              decoration: const InputDecoration(labelText: 'Average Mileage (Km/L)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveVehicle,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Save Vehicle'),
                  ),
          ],
        ),
      ),
    );
  }
}

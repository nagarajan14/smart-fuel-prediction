import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class NearbyStationsScreen extends StatefulWidget {
  const NearbyStationsScreen({Key? key}) : super(key: key);

  @override
  State<NearbyStationsScreen> createState() => _NearbyStationsScreenState();
}

class _NearbyStationsScreenState extends State<NearbyStationsScreen> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(37.422, -122.084); // Default to Google HQ
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(mounted) setState(() => _isLoading = false);
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    _initialPosition = LatLng(position.latitude, position.longitude);

    // Mock nearby petrol stations for visualization
    _markers.add(
      Marker(
        markerId: const MarkerId('current'),
        position: _initialPosition,
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Fake nearby station 1
    _markers.add(
      Marker(
        markerId: const MarkerId('station_1'),
        position: LatLng(position.latitude + 0.01, position.longitude + 0.01),
        infoWindow: const InfoWindow(title: 'Shell Petrol Station'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Fake nearby station 2
    _markers.add(
      Marker(
        markerId: const MarkerId('station_2'),
        position: LatLng(position.latitude - 0.015, position.longitude - 0.005),
        infoWindow: const InfoWindow(title: 'BP Fuel Station'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    if(mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Petrol Stations')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 13),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
            ),
    );
  }
}

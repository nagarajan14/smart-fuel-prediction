# Firebase Database Structure & IoT Integration

This document outlines the Firestore NoSQL database schema and how the ESP32 IoT device communicates with the app.

## 1. Firebase Firestore Structure

### Collection: `users`
Stores user profile information.
* **Document ID**: Unique Firebase Auth UID
* **Fields**:
  * `email` (String)
  * `name` (String)
  * `createdAt` (Timestamp)

### Collection: `vehicles`
Stores registered vehicle data for distance prediction.
* **Document ID**: Auto-generated vehicle ID
* **Fields**:
  * `userId` (String) - Reference to User ID
  * `name` (String) - e.g., "Honda Civic"
  * `type` (String) - "bike", "car", "truck"
  * `tankCapacity` (Double) - Total capacity in Liters
  * `averageMileage` (Double) - Km per Liter (used for distance calculation)

### Collection: `fuel_logs`
Stores time-series data sent from the ESP32 and telemetry unit.
* **Document ID**: Auto-generated log ID
* **Fields**:
  * `vehicleId` (String) - Reference to Vehicle ID
  * `fuelLevel` (Double) - Current fuel in Liters
  * `fuelPercentage` (Double) - 0.0 to 100.0
  * `distanceCovered` (Double) - Km traveled since the last log
  * `fuelConsumed` (Double) - Liters of fuel burned since the last log
  * `speed` (Double) - Average speed during this segment (km/h)
  * `trafficCondition` (String) - "Light", "Moderate", "Heavy" 
  * `drivingStyle` (String) - "Eco", "Normal", "Aggressive"
  * `timestamp` (Timestamp) - Server timestamp of the reading

---

## 2. ESP32 IoT Integration (Assumption)

The ESP32 reads sensory data (e.g., using an ultrasonic sensor to measure distance to the fuel surface) and calculates the current volume.

**Workflow:**
1. **Connect to WiFi:** The ESP32 connects to available WiFi.
2. **Read Sensor:** Obtains distance reading and calculates `fuelLevel`.
3. **Send to Firebase:** Directly pushes data to the `fuel_logs` collection using the Firebase REST API or a library like `Firebase_ESP_Client`.

**Sample ESP32 C++ Code Payload:**
```cpp
// Pseudocode for pushing data
FirebaseJson json;
json.set("vehicleId", "VEHICLE_123_ID");
json.set("fuelLevel", currentLiters);
json.set("fuelPercentage", (currentLiters / MAX_CAPACITY) * 100);
json.set("distanceCovered", distanceSinceLastTick);
json.set("fuelConsumed", fuelBurnedSinceLastTick);
json.set("speed", avgSpeedKmh);
json.set("trafficCondition", "Moderate"); // Might be derived from GPS APIs in the cloud or phone
json.set("drivingStyle", "Normal"); // Derived from accelerometer data (hard braking/acceleration)
// Firebase handles the server timestamp on the backend if configured, or device sends Unix epoch
json.set("timestamp/.sv", "timestamp");

if (Firebase.pushJSON(firebaseData, "/fuel_logs", json)) {
  Serial.println("Data pushed successfully");
}
```

**Real-Time App Functionality:**
The Flutter app listens to the `fuel_logs` collection using Firestore Streams (`snapshots()`). When a new log is pushed by the ESP32, the UI automatically rebuilds showing the updated fuel level and remaining distance.

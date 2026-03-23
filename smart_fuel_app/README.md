# Smart Fuel Monitoring and Distance Prediction App

A Flutter mobile application that connects to an IoT device (ESP32) installed in a vehicle fuel tank. The app displays real-time fuel levels, predicts remaining travel distance, and offers smart alerts based on fuel consumption data stored in Firebase.

## Features
- **User Authentication:** Email and password login via Firebase.
- **Vehicle Registration:** Add bike, car, or truck details (tank capacity, mileage).
- **Real-Time Monitoring:** Live fuel level and percentage visualization.
- **Distance Prediction:** Calculates remaining travel distance based on average mileage.
- **Fuel Usage History:** Beautiful charts showing fuel consumption over time.
- **Smart Alerts:** Notifications for low fuel and sudden drops (possible theft).
- **Nearby Petrol Stations:** Google Maps integration to find stations organically.

## Folder Structure
```
lib/
├── main.dart                       # App Entry point & Routing
├── core/                           # Theme & Constants
├── models/                         # Data layer (User, Vehicle, FuelLog)
├── services/                       # API layer (Auth, DB)
└── ui/                             # Presentation layer
    ├── auth/                       # Login / Register
    ├── dashboard/                  # Dashboard & Real-Time charts
    ├── vehicle/                    # Add/Edit Vehicle
    └── maps/                       # Nearby fuel stations
```

## How to Run the App

1. Ensure you have Flutter installed: `flutter --version`
2. Clone this project or navigate to this folder in terminal.
3. Get packages:
   ```bash
   flutter pub get
   ```
4. **Firebase Setup**:
   This project uses Firebase. You must configure your own Firebase project:
   - Create a new project in [Firebase Console](https://console.firebase.google.com/).
   - Enable Authentication (Email/Password) and Firestore Database.
   - Register your Android/iOS app.
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in `android/app/` and `ios/Runner/` respectively.
   - Or use `flutterfire configure` for automatic setup.
5. **Google Maps Setup**:
   - Get an API key from Google Cloud Console.
   - Add it to `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift`.
6. Run the app:
   ```bash
   flutter run
   ```

## UI Design Concept
- **Dark/Modern Theme:** Uses deep blues/blacks with neon accents (green for full fuel, red for low fuel) to give a high-tech dashboard feel.
- **Dashboard:** Features a central circular indicator for fuel level, surrounded by quick stats (distance left). Below it, a line chart shows recent usage history.
- **Alerts:** Snackbars or push notifications for critical events.

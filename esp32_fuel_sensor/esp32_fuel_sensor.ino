#include <WiFi.h>
#include <Firebase_ESP_Client.h>

// --- WIFI CREDENTIALS ---
#define WIFI_SSID "YOUR_WIFI_NAME"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// --- FIREBASE CREDENTIALS (FROM YOUR PROJECT) ---
#define FIREBASE_HOST "your-project-id.firebaseio.com" // Update from Firebase RTDB or Firestore
#define FIREBASE_AUTH "YOUR_FIREBASE_API_KEY"

// --- ULTRASONIC SENSOR PINS ---
#define TRIG_PIN 5
#define ECHO_PIN 18

// Tank dimensions (in cm)
#define TANK_HEIGHT_CM 50.0 
#define SENSOR_OFFSET_CM 2.0 // Distance from sensor to the top of the tank

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setup() {
  Serial.begin(115200);

  // Initialize Ultrasonic Pins
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // Connect to Wi-Fi
  Serial.print("Connecting to Wi-Fi");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("\nWiFi Connected!");

  // Initialize Firebase
  config.api_key = FIREBASE_AUTH;
  config.database_url = FIREBASE_HOST;
  
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Firebase Auth OK");
  } else {
    Serial.printf("Firebase Error: %s\n", config.signer.signupError.message.c_str());
  }
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // 1. Measure distance using Ultrasonic Sensor
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH);
  float distance_cm = duration * 0.034 / 2;

  Serial.print("Distance (cm): ");
  Serial.println(distance_cm);

  // 2. Calculate Fuel Percentage
  // Ensure we don't go below 0 or above 100
  float fuel_level = TANK_HEIGHT_CM - (distance_cm - SENSOR_OFFSET_CM);
  if (fuel_level < 0) fuel_level = 0;
  if (fuel_level > TANK_HEIGHT_CM) fuel_level = TANK_HEIGHT_CM;

  float fuel_percentage = (fuel_level / TANK_HEIGHT_CM) * 100.0;
  
  Serial.print("Fuel Percentage: ");
  Serial.print(fuel_percentage);
  Serial.println("%");

  // 3. Send Data to Firebase
  if (Firebase.ready()) {
    // Replace "VEHICLE_123" with your actual vehicle ID in Firestore/RTDB
    String path = "/vehicles/VEHICLE_123/fuel_level";
    
    if (Firebase.RTDB.setFloat(&fbdo, path.c_str(), fuel_percentage)) {
      Serial.println("Data pushed to Firebase successfully!\n");
    } else {
      Serial.println("Failed to push data: " + fbdo.errorReason() + "\n");
    }
  }

  // Wait 10 seconds before next reading
  delay(10000); 
}

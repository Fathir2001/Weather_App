#include <DHT.h>                // Library for DHT11 sensor
#include <Adafruit_Sensor.h>    // Unified sensor library
#include <Adafruit_BMP085_U.h>  // Library for BMP180 sensor

// Define pins for the sensors
#define DHTPIN 5         // Pin connected to DHT11 data pin
#define RAINDROPS_PIN 2   // Pin connected to the rain sensor analog output
#define LDR_PIN 4         // Pin connected to the LDR analog output

// Define DHT sensor type
#define DHTTYPE DHT11

// Initialize DHT sensor
DHT dht(DHTPIN, DHTTYPE);

// Create an instance of the BMP180 sensor
Adafruit_BMP085_Unified bmp = Adafruit_BMP085_Unified();

void setup() {
  Serial.begin(9600);
  
  // Initialize DHT sensor
  dht.begin();

  // Initialize BMP180 sensor
  if (!bmp.begin()) {
    Serial.println("Could not find a valid BMP180 sensor, check wiring!");
    while (1);
  }
}

void loop() {
  // Read temperature as Celsius
  float temperature = dht.readTemperature();
  // Read humidity
  float humidity = dht.readHumidity();

  // Check if any readings failed
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("Failed to read from DHT sensor!");
  } else {
    Serial.print("Temperature: ");
    Serial.print(temperature);
    Serial.println("°C");
    
    Serial.print("Humidity: ");
    Serial.print(humidity);
    Serial.println("%");
  }

  // Read raindrops sensor value
  int rainValue = analogRead(RAINDROPS_PIN);
  String rainCondition = getRainCondition(rainValue);
  Serial.print("Rain Val: ");
  Serial.println(rainValue);
  Serial.print("Rain Condition: ");
  Serial.println(rainCondition);

  // Read LDR sensor value
  int ldrValue = analogRead(LDR_PIN);
  String lightCondition = getLightCondition(ldrValue);
  Serial.print("Light Condition: ");
  Serial.println(lightCondition);

  // Read pressure from BMP180 sensor
  sensors_event_t event;
  bmp.getEvent(&event);
  
  if (event.pressure) {
    Serial.print("Pressure: ");
    Serial.print(event.pressure);
    Serial.println(" hPa");
  } else {
    Serial.println("Pressure data not available");
  }

  // Wait 2 seconds before the next loop
  delay(10000);
}

String getLightCondition(int value) {
  if (value < 500) {
    return "High Brightness";
  } else if (value < 1000) {
    return "Normal Brightness";
  } else if (value < 2000) {
    return "Low Brightness";
  } else {
    return "Dark";
  }
}

String getRainCondition(int value) {
  if (value < 1200) {
    return "Heavy Rain";
  } else if (value < 1600) {
    return "Moderate Rain";
  } else if (value < 1750) {
    return "Light Rain";
  } else {
    return "No Rain";
  }
}


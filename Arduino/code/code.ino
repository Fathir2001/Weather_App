#include <DHT.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BMP085_U.h>

// Pin definitions
#define DHTPIN 5
#define RAINDROPS_PIN 2
#define LDR_PIN 4
#define DHTTYPE DHT11

// Initialize sensors
DHT dht(DHTPIN, DHTTYPE);
Adafruit_BMP085_Unified bmp = Adafruit_BMP085_Unified();

void setup() {
  Serial.begin(9600);
  dht.begin();
  
  if (!bmp.begin()) {
    Serial.println("Could not find BMP180 sensor!");
    while (1);
  }
}

void loop() {
  // Read sensor values
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();
  int rainValue = analogRead(RAINDROPS_PIN);
  int ldrValue = analogRead(LDR_PIN);
  
  sensors_event_t event;
  bmp.getEvent(&event);

  // Send CSV formatted data
  if (!isnan(temperature) && !isnan(humidity) && event.pressure) {
    Serial.print(temperature);
    Serial.print(",");
    Serial.print(humidity);
    Serial.print(",");
    Serial.print(getRainCondition(rainValue));
    Serial.print(",");
    Serial.print(getLightCondition(ldrValue));
    Serial.print(",");
    Serial.println(event.pressure);
  }

  delay(2000);
}

String getLightCondition(int value) {
  if (value < 500) return "High Brightness";
  else if (value < 1000) return "Normal Brightness";
  else if (value < 2000) return "Low Brightness";
  else return "Dark";
}

String getRainCondition(int value) {
  if (value < 1200) return "Heavy Rain";
  else if (value < 1600) return "Moderate Rain";
  else if (value < 1750) return "Light Rain";
  else return "No Rain";
}
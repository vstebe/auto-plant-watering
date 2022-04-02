/*
 This code has still never been tested.
*/
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <Arduino_JSON.h>

#define MANUAL_BUTTON 7
#define SENSOR_MOIST 5

#define OUT_HEARTBEAT 2
#define OUT_PUMP 1

long pumpTime = 5L;
long sleepTime = 5L;
bool runPump = false;
long motorThreshold = 12L;

#define API "https://api"
#define WIFI_NAME "wifiname"
#define WIFI_PASSWORD "wifipassword"

long currentP1, currentP2, currentP3;
void setup()
{
  Serial.begin(9600);

  pinMode(MANUAL_BUTTON, INPUT_PULLUP);
  pinMode(SENSOR_MOIST, OUTPUT);
  pinMode(OUT_HEARTBEAT, OUTPUT);
  pinMode(OUT_PUMP, OUTPUT);

  digitalWrite(SENSOR_MOIST, LOW);
  digitalWrite(OUT_HEARTBEAT, LOW);
  digitalWrite(OUT_PUMP, LOW);

  Serial.println("Start");

  Serial.println();

  Serial.print("Connected, IP address: ");
  Serial.println(WiFi.localIP());
}

int readAnalog(int sensor)
{
  digitalWrite(sensor, HIGH);
  delay(30);
  int value = analogRead(A0);
  digitalWrite(sensor, LOW);
  return value;
}

void updateConfiguration()
{
  WiFiClient client;
  HTTPClient httpClient;
  httpClient.begin(client, String(API) + "/pump"); 
  httpClient.addHeader("Content-Type", "application/json");
  httpClient.GET();
  String body = httpClient.getString();
  JSONVar myObject = JSON.parse(body);
  if (myObject.hasOwnProperty("sleepTime"))
  {
    JSONVar var = myObject["sleepTime"];
    sleepTime = (long) var;
  }
  if (myObject.hasOwnProperty("pumpTime"))
  {
    JSONVar var = myObject["pumpTime"];
    pumpTime = (long) var;
  }
  if (myObject.hasOwnProperty("runPump"))
  {
    JSONVar var = myObject["runPump"];
    runPump = (bool) var;
  }
  httpClient.end();
}

void sendSensorData() {
  int data = readAnalog(SENSOR_MOIST);
  WiFiClient client;
  HTTPClient httpClient;
  httpClient.begin(client, String(API) + "/sensor"); 
  httpClient.addHeader("Content-Type", "application/json");
  httpClient.POST(String(data));
  httpClient.end();
}

void sendLowWaterAlert() {
  WiFiClient client;
  HTTPClient httpClient;
  httpClient.begin(client, String(API) + "/water-alert"); 
  httpClient.addHeader("Content-Type", "application/json");
  httpClient.POST("");
  httpClient.end();
}


bool doRunPump() {
  digitalWrite(OUT_PUMP, true);
  unsigned long time = millis();
  while (millis() - time < 1000L * pumpTime)
  {
    delay(1000);
    if (analogRead(A0) < motorThreshold) {
      return false;
    }
  }
  return true;
}

void loop()
{
  if (!WiFi.config(IPAddress(192, 168, 7, 69), IPAddress(192, 168, 7, 1), IPAddress(255, 255, 255, 0)))
  {
    Serial.println("STA Failed to configure");
  }

  WiFi.begin(WIFI_NAME, WIFI_PASSWORD);

  Serial.print("Connecting");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }

  updateConfiguration();
  sendSensorData();

  if (runPump) {
    bool success = doRunPump();
    if(!success) {
      sendLowWaterAlert();
    }
  }

  ESP.restart();
}
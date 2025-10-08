#include <esp_now.h>
#include <WiFi.h>

#define NUM_BOARDS 4
#define DATA_SIZE 200

struct Sensor
{
  int ID;
  char Data[DATA_SIZE];
};

Sensor boardsArray[NUM_BOARDS];

void OnRecv(const uint8_t *mac, const uint8_t *incomingData, int len)
{
  Sensor received;
  memcpy(&received, incomingData, sizeof(Sensor));

  // Validate ID range
  if (received.ID < 1 || received.ID > NUM_BOARDS)
  {
    Serial.printf("Invalid ID: %d\n", received.ID);
    return;
  }

  int index = received.ID - 1;
  boardsArray[index] = received; // Simple direct assignment
}

void setup()
{
  Serial.begin(115200);

  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  Serial.println(WiFi.macAddress());
  delay(1000);

  if (esp_now_init() != ESP_OK)
  {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  esp_now_register_recv_cb(OnRecv);
}

void loop()
{
  static char buffer[NUM_BOARDS * (DATA_SIZE + 4)];
  int offset = 0;

  for (int i = 0; i < NUM_BOARDS; i++)
  {
    offset += snprintf(buffer + offset, sizeof(buffer) - offset, "%d %s ", i, boardsArray[i].Data);
    if (offset >= sizeof(buffer))
      break; // prevent overflow
  }

  Serial.println(buffer);
  delay(100);
}

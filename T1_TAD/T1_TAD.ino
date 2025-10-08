#include <esp_now.h>
#include <WiFi.h>

typedef struct Sensor
{
  int ID;
  char Data[200];
} Sensor;

Sensor Muestras;

Sensor board1;
Sensor board2;
Sensor board3;
Sensor board4;

Sensor boardsArray[4] = {board1, board2, board3, board4};

void OnRecv(const uint8_t *mac, const uint8_t *incomingData, int len)
{
  memcpy(&Muestras, incomingData, sizeof(Muestras));

  boardsArray[Muestras.ID - 1].ID = Muestras.ID;
  memcpy(&boardsArray[Muestras.ID - 1].Data, Muestras.Data, sizeof(Muestras.Data));
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
    Serial.println("There was an error initializing ESP-NOW");
    return;
  }

  esp_now_register_recv_cb(OnRecv);
}

String Cadena = "";
void loop()
{

  Cadena += "0 " + String(boardsArray[0].Data);
  Cadena += " ";
  Cadena += "1 " + String(boardsArray[1].Data);
  Cadena += " ";
  Cadena += "2 " + String(boardsArray[2].Data);
  Cadena += " ";
  Cadena += "3 " + String(boardsArray[3].Data);

  Serial.println(Cadena);
  Cadena = "";

  delay(100);
}

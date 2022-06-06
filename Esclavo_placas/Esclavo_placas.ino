#include <esp_now.h>
#include <WiFi.h>

boolean bandera = false;
String incoming = "";

typedef struct Sensor {
  int ID;
  char Data[200];
}Sensor;

Sensor Muestras;

Sensor board1;
Sensor board2;
Sensor board3;
Sensor board4;

Sensor boardsArray[4]={board1,board2,board3,board4};

void OnRecv(const uint8_t * mac, const uint8_t *incomingData, int len) {
  memcpy(&Muestras, incomingData, sizeof(Muestras));
  
  boardsArray[Muestras.ID-1].ID = Muestras.ID;
  memcpy(& boardsArray[Muestras.ID-1].Data,Muestras.Data,sizeof(Muestras.Data));
  //boardsStruct[Muestras.ID-1].Data = Muestras.Data;
  //Serial.print("ID Sensor: ");
  //Serial.println(Muestras.ID);
  //Serial.println();
  //Serial.print("Datos ");
  //Serial.println(reinterpret_cast<const char*>(incomingData));
  //Serial.println(Muestras.Data);
}
void setup() {
  // Initialize Serial Monitor
  Serial.begin(115200);
  
  // Set device as a Wi-Fi Station
  WiFi.mode(WIFI_STA);
  Serial.println(WiFi.macAddress());
  WiFi.disconnect();

  // Init ESP-NOW
  if (esp_now_init() != ESP_OK) {
    Serial.println("There was an error initializing ESP-NOW");
    return;
  }
  
  // Once the ESP-Now protocol is initialized, we will register the callback function
  // to be able to react when a package arrives in near to real time without pooling every loop.
  esp_now_register_recv_cb(OnRecv);
}

String Cadena = "";

void adquisition(){
  Cadena  +=  "0 " + String(boardsArray[0].Data);
  Cadena  +=  " ";
  Cadena  +=  "1 " + String(boardsArray[1].Data);
  Cadena  +=  " ";
  Cadena  +=  "2 " + String(boardsArray[2].Data); 
  Cadena  +=  " ";
  Cadena  +=  "3 " + String(boardsArray[3].Data);  
  
  Serial.println(Cadena);
  Cadena= ""; 
  /*
   * el valor inicial en cada array es un identificador
  ORDEN:
  Celda  
  Encoder
  Flujo  
  ECU  --- RPM, TPS, TEMPERATURA, BATERIA, TPS2, GEARPOSITION  

  */
}
void loop() {
   
  /*if(Serial.available() > 0){
    incoming = Serial.readString();
  
    Serial.println(incoming);
    if(incoming.indexOf("iniciar") > -1){
      bandera = true;
    }
  
    if(incoming.indexOf("detener") > -1){
      bandera = false;
    }
  }
  
  if(bandera){*/
    adquisition();
    delay(100);
  //}
  
}

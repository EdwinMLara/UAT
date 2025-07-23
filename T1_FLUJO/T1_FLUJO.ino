#include <cstdint>
#include <esp_now.h>
#include <WiFi.h>

uint8_t slaveAddress[] = {0x30, 0xAE, 0xA4, 0xF4, 0xC6, 0x98};


typedef struct Sensor {
  int ID;
  char Data[200];
};

Sensor Muestras;

// Create peer interface
esp_now_peer_info_t peerInfo;


void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
  //Serial.print("\r\nSend message status:\t");
  Serial.print(status == ESP_NOW_SEND_SUCCESS ? "Sent: " : "Fail: ");
}


// interrupcion para medicion de tiempo 
struct IFlujo {
  const uint8_t PIN;
  unsigned long TimePulse;
  bool Pulse;
};

IFlujo E1  = {15, 0, false};

void IRAM_ATTR isr(){
  E1.TimePulse = micros();
  E1.Pulse  = true;
}  

// Define pines control
  byte LED = 2;

// Variables RED INSOEL
  bool datos  = false;
  bool Stop   = false;
  
// Variables Tiempo
  unsigned long Tsampl, k;
  unsigned long tiempo = 1; 
  float FTrns=50; //Datos por transmision
  float VFTrns,DFTrns; 

// Variables loop
  unsigned long Tin;
  unsigned long C[100],C2[100];
  unsigned long T, Te, Te2;
  float   Flujo,  Tf;

void setup() {
// Inicializacion para mostrar en monitor Serial
  Serial.begin(115200);
   // while (!Serial);

// Orden: Celda, Encoder, Flujo, ECU
    Muestras.ID = 3;

// Configuracion de pines
  pinMode(LED,OUTPUT);
  
// Configuracion Interrupciones
  pinMode(E1.PIN, INPUT_PULLUP);
  attachInterrupt(E1.PIN, isr, RISING);
    
// Inicializa Variables tiempo
  VFTrns=100/FTrns;
  DFTrns=(1/FTrns)*1000000;
  Tin=micros();
}

  long Tcount=0;
  
void loop() {

  if(E1.Pulse){
    E1.Pulse = false;
    Te=E1.TimePulse;
    T=Te-Te2;
    Te2=Te;
    Tf=T;
    Flujo = 1800000/Tf;
  }

}

 

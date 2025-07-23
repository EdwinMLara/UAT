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

IFlujo E1  = {13, 0, false};

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
  unsigned long Tsampl, k, TH;
  unsigned long tiempo = 1; 
  float FTrns=50; //Datos por transmision
  float VFTrns,DFTrns; 

// Variables loop
  unsigned long Tin,Tfn,Tp;
  unsigned long C[100],C2[100];
  unsigned long T, Te, Te2;
  float   Encoder,  Tf;
  
void setup() {
// Inicializacion para mostrar en monitor Serial
  Serial.begin(115200);
//    while (!Serial);

// Orden: Celda, Encoder, Flujo, ECU
    Muestras.ID = 2;

// Configuracion de pines
  pinMode(LED,OUTPUT);
  //pinMode(12, INPUT_PULLUP);
  //pinMode(13, INPUT_PULLUP);

// Configuracion Interrupciones
  pinMode(E1.PIN, INPUT_PULLUP);
  attachInterrupt(E1.PIN, isr, RISING);
  
// Set device as a Wi-Fi Station
  WiFi.mode(WIFI_STA);
  // Init ESP-NOW
  if (esp_now_init() != ESP_OK) {
    Serial.println("There was an error initializing ESP-NOW");
    return;
  }
  // We will register the callback function to respond to the event
  esp_now_register_send_cb(OnDataSent);
  
   // Register the slave
  //esp_now_peer_info_t slaveInfo;
memcpy(peerInfo.peer_addr, slaveAddress, 6);
  peerInfo.channel = 0;  
  peerInfo.encrypt = false;
  
  // Add peer        
  if (esp_now_add_peer(&peerInfo) != ESP_OK){
    Serial.println("Failed to add peer");
    return;
  }
// inicializa Variables tiempo
  VFTrns=100/FTrns;
  DFTrns=(1/FTrns)*1000000;
  Tin=micros();

}


  long Tcount=0;
  byte nd=1;
  String CS="";
  
void loop() {

if(E1.Pulse){
    E1.Pulse = false;    
    Te=E1.TimePulse;
    T=(Te-Te2);
    Te2=Te;
    Tf=T;
    Encoder = 60000000/Tf;
    //Encoder = Tf;
  }

  if((micros()-Tin)>=10000){
    nd++;
    Tin=micros();
    CS+=String(Encoder);
    CS+=" ";
    }

  if(nd>10){
    nd=1;
  //  String CS =String(int(c*10))+ " " +String(int(c1*10)) + " " + String(int(c2*10));
    CS.toCharArray(Muestras.Data, CS.length());
    //CS.toCharArray(Cs, CS.length());
    //Serial.println(CS.length());
    Serial.println(CS);
    
  //  Muestras.Data = reinterpret_cast<const uint8_t*>(Cs);
  
  //  esp_err_t result = esp_now_send(slaveAddress, (uint8_t *) &Cs, sizeof(Cs));
    esp_err_t result = esp_now_send(slaveAddress, (uint8_t *) &Muestras, sizeof(Muestras));
  //  esp_err_t result = esp_now_send(slaveAddress, (uint8_t *) &dhtData, sizeof(dhtData));
     
    if (result == ESP_OK) {
     // Serial.println("The message was sent sucessfully.");
    }else {
      //Serial.println("There was an error sending the message.");
    }
    CS="";      
  }
}

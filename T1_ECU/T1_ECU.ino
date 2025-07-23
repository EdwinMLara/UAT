//#include <stdlib.h>
//#include <cstdint>
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

// Define pines control
  byte LED = 2;
  
// Variables Tiempo
  unsigned long Trns;
  unsigned long Trequest;
 
// Timing KWP2000 protocol
  #define K_IN      16 //RX2 
  #define K_OUT     5 //TX2 
  //byte  P1  = 1;    // 0  - 20
  byte  P2  = 1;   // 25 - 50
  int   P3  = 55;   // 55 - 5000
  //byte  P4  = 1;    // 5  - 20

// Variables K-Line
  byte  Decu[20], Dini[14];
  bool  ECUon;
  float aux;
  int RPM, TPS, TPS2, GP; 
  float ECT, BAT;  

// Vectores PIDs OBD 2
  byte Vecu[5]  = {0x81, 0x11, 0xF1, 0x81, 0x04};
  byte Vtps[7]  = {0x80, 0x11, 0xF1, 0x02, 0x21, 0x04, 0xA9};
  byte Vrpm[7]  = {0x80, 0x11, 0xF1, 0x02, 0x21, 0x09, 0xAE};
  byte Vect[7]  = {0x80, 0x11, 0xF1, 0x02, 0x21, 0x06, 0xAB};
  byte Vtps2[7] = {0x80, 0x11, 0xF1, 0x02, 0x21, 0x5B, 0x00};
  byte Vgp[7]   = {0x80, 0x11, 0xF1, 0x02, 0x21, 0x0B, 0xB0};
  byte Vbat[7]  = {0x80, 0x11, 0xF1, 0x02, 0x21, 0x0A, 0xAF}; 


// Variables loop
  byte OBD, OBDa;  
  String CS="";
  

void setup() {
// Inicializacion para mostrar en monitor Serial
  Serial.begin(115200);
  //  while (!Serial);
  Serial2.begin(10400); // Comunicacion K-line
  Serial.println("ECU start");

// Orden: Celda, Encoder, Flujo, ECU
    Muestras.ID = 4;
  
// Configuracion de pines
  pinMode(LED,OUTPUT);
  pinMode(4,OUTPUT);
  pinMode(K_OUT,OUTPUT);

// Inicializa K-line
  ECU_connect();

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
  Trns = micros();
}

void loop() {

  //K-line
        Trns = micros();
      if(ECUon==1){
        Trequest=millis();
        digitalWrite(LED,0);
        OBD++;  
        switch (OBD){
          case 1:
            RPM_request();
            Serial2.readBytes(Decu,16);
            RPM =(Decu[13]*100)+Decu[14];
            delay(P3);
          break;
          case 2:
            TPS_request();
            Serial2.readBytes(Decu,16);
            TPS=map((Decu[13]<<8) + Decu[14], 206,892, 0,100);
            delay(P3);
          break;
          default:
            OBDa++;
            switch (OBDa){
                case 1:
                  ECT_request();
                  Serial2.readBytes(Decu,15);
                  aux = Decu[13];
                  ECT = ((aux-48))/1.6;
                  delay(P3);
                break;
                case 2:
                  TPS2_request();
                  Serial2.readBytes(Decu,15);
                  //aux = Decu[13];
                  TPS2= map(Decu[13], 60, 200, 0,100);
                  //((aux-125)*100)/(222-125);
                  delay(P3);
                break;
                case 3:
                  GP_request();
                  Serial2.readBytes(Decu,15);
                  GP  = Decu[13];
                  delay(P3);
                break;
                default:
                  BAT_request();
                  Serial2.readBytes(Decu,15);
                  aux = Decu[13];
                  BAT  = (aux/12.75);
                  delay(P3);
                  OBDa=0;       
            }
            OBD=0; 
        }
        //Kline = "TPS= " + String(TPS) +"%  RPM= " +String(RPM) +"  ECT= " +String(ECT) +"°C  TPS2= " +String(TPS2) +"  GP= " +String(GP) +"  BAT= " +String(BAT) +"V";
        //Serial.println(Kline);
      }else{
        TPS=0; RPM=0; ECT=0; TPS2=0; GP=0; BAT=0;   
      }digitalWrite(LED,1);
      
    if((millis()-Trequest)>200 || TPS>110){
       ECUon=ECU_connect();
       Serial.println("Reconect");
       delay(1000);
    }

  CS  +=  String(RPM)+ " "; 
  CS  +=  String(TPS)+ " ";
  CS  +=  String(ECT)+ " ";
  CS  +=  String(BAT)+ " ";  
  CS  +=  String(TPS2)+ " "; 
  CS  +=  String(GP)+ " "; 
  CS  +=  String(0)+ " "; 
  CS  +=  String(0)+ " ";  
  CS  +=  String(0)+ " "; 
  CS  +=  String(0)+ " "; 
  
  CS.toCharArray(Muestras.Data, CS.length());
    Serial.println(CS);
    
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

bool  ECU_connect(){
    //digitalWrite(K_OUT,1);
    //delay(1000);
    Fast_Start();
    ECU_request();
    delay(P2);
    Serial2.readBytes(Dini,13);
//    Serial.print("  Ecu Request: ");
//    Serial.print(Dini[0],HEX);Serial.print(" ");
//    Serial.print(Dini[1],HEX);Serial.print(" ");
//    Serial.print(Dini[2],HEX);Serial.print(" ");
//    Serial.print(Dini[3],HEX);Serial.print(" ");
//    Serial.print(Dini[4],HEX);Serial.print(" ");
//    Serial.print(Dini[5],HEX);Serial.print(" ");
//    Serial.print(Dini[6],HEX);Serial.print(" ");
//    Serial.print(Dini[7],HEX);Serial.print(" ");
//    Serial.print(Dini[8],HEX);Serial.print(" ");
//    Serial.print(Dini[9],HEX);Serial.print(" ");
//    Serial.print(Dini[10],HEX);Serial.print(" ");
//    Serial.print(Dini[11],HEX);Serial.print(" ");
//    Serial.print(Dini[12],HEX);Serial.print(" ");
//    Serial.println(Dini[13],HEX);
    delay(P3); 

    if(Dini[3]==0){
      for(byte i=0; i<13; i++){Dini[i]=0;}
      return(0);
    }else{
      for(byte i=0; i<13; i++){Dini[i]=0;}
      return(1);
    }
}

// Send Request to ECU for know if it exist
void  ECU_request(){
  for(byte d=0;d<5;d++){ Tbit8(Vecu[d] ); }
}

// Send request of Throttle Position Sensor
void TPS_request(){
  for(byte d=0;d<7;d++){ Tbit8(Vtps[d]);  }
}

// Send request of Engine RPM
void RPM_request(){
  for(byte d=0;d<7;d++){ Tbit8(Vrpm[d]);  }
}

// Send request of Engine Coolant Temperature
void ECT_request(){
  for(byte d=0;d<7;d++){ Tbit8(Vect[d]);  }
}

// Send request of Sub-throttle valve operating angle
void TPS2_request(){
  for(byte d=0;d<7;d++){ Tbit8(Vtps2[d]);  }
}

// Send request of Gear Position
void GP_request(){
  for(byte d=0;d<7;d++){ Tbit8(Vgp[d]);  }
}

// Send request of Battery voltage
void BAT_request(){
  for(byte d=0;d<7;d++){ Tbit8(Vbat[d]);  }
}

// Function to transmit byte to K-line
void  Tbit8(byte Bn){  
    digitalWrite(K_OUT,0);
    delayMicroseconds(94);
  for(byte i=0; i<8; i++){
    //Serial.print(bitRead(Bn,i-1));
    digitalWrite(K_OUT,bitRead(Bn,i));
    delayMicroseconds(94);
  }digitalWrite(K_OUT,1);
  delayMicroseconds(100);
}

// Initialize connection to ECU. Fast initialization K-Line
void  Fast_Start() {
// This is the ISO 14230-2 "Fast Init" sequence.
  digitalWrite(K_OUT, LOW);   digitalWrite(LED,0);
  delay(25);
  digitalWrite(K_OUT, HIGH);  digitalWrite(LED,1);
  delay(25);
}

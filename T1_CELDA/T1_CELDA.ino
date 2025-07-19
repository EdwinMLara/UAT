#include <ADS1115_WE.h>
#include <Wire.h>
#define I2C_ADDRESS 0x48

#include <esp_now.h>
#include <WiFi.h>


uint8_t slaveAddress[] = { 0x30, 0xAE, 0xA4, 0xF4, 0xC6, 0x98 };



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

// Pines
byte LED = 2;  // Lolin 5, ESP32 DEV Module 2

//Flow Variable
float V;
long ADC;
unsigned long Tref;
float Smpl;
byte b1 = 1, b2 = 1;
int Sgnl;


// There are several ways to create your ADS1115_WE object:
ADS1115_WE adc = ADS1115_WE(I2C_ADDRESS);

void setup() {
  Wire.begin();
  Serial.begin(115200);
  //  while(!Serial) {;}
  if (!adc.init()) {
    Serial.println("ADS1115 not connected!");
  }

  //Set the voltage range of the ADC to adjust the gain
  adc.setVoltageRange_mV(ADS1115_RANGE_4096);  //comment line/change parameter to change range
                                               //Set the inputs to be compared
  adc.setCompareChannels(ADS1115_COMP_0_GND);  //comment line/change parameter to change channel
                                               //Set continuous or single shot mode:
  adc.setMeasureMode(ADS1115_CONTINUOUS);      //comment line/change parameter to change mode

  // Orden: Celda, Encoder, Flujo, ECU
  Muestras.ID = 1;

  // Configuracion de pines
  pinMode(LED, OUTPUT);

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
  if (esp_now_add_peer(&peerInfo) != ESP_OK) {
    Serial.println("Failed to add peer");
    return;
  }

  Tref = micros();
}

String CS = "";

void loop() {

  if (b1 == 1) {
    b1 = 0;
  } else {
    b1 = 1;
  }
  digitalWrite(LED, b1);

  for (byte nD = 0; nD < 10; nD++) {
    while (10000 > (micros() - Tref)) {};
    Tref = micros();
    Smpl = readChannel(ADS1115_COMP_0_GND);
    //    CS+=String(Smpl*0.125);
    //    CS+=String(Smpl*0.000249);
    //    CS+=String(Smpl);
    CS += String((Smpl * 5) / 114);
    CS += " ";
    //Serial.println(Smpl*0.0001875);
    //Vm[nD]=Smpl;
  }

  CS.toCharArray(Muestras.Data, CS.length());

  Serial.println(CS);

  //  Muestras.Data = reinterpret_cast<const uint8_t*>(Cs);

  //  esp_err_t result = esp_now_send(slaveAddress, (uint8_t *) &Cs, sizeof(Cs));
  esp_err_t result = esp_now_send(slaveAddress, (uint8_t *)&Muestras, sizeof(Muestras));
  //  esp_err_t result = esp_now_send(slaveAddress, (uint8_t *) &dhtData, sizeof(dhtData));

  if (result == ESP_OK) {
    // Serial.println("The message was sent sucessfully.");
  } else {
    //Serial.println("There was an error sending the message.");
  }
  CS = "";
}

float readChannel(ADS1115_MUX channel) {
  float voltage = 0.0;
  adc.setCompareChannels(channel);
  voltage = adc.getResult_mV();  // alternative: getResult_mV for Millivolt
  return voltage;
}

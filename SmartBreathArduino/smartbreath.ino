#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

//DHT 11 sensörü için gerekli işlemler yapılmaktadır.
#include "DHT.h"
#define DHTTYPE DHT11
uint8_t DHTPin = 14; 
DHT dht(DHTPin, DHTTYPE);                

float temp;
float humidity;
float mq9voltage;
float mq9value;
int mq9pin = 34;

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;

bool deviceConnected = false;
bool oldDeviceConnected = false;

//ESP32 için SERVICE_UUID ve CHARACTERISTIC_UUID tanımlanıyor.
//Bu UUIDler sayesinde mobil cihazımızın bluetoothuna erişim sağlayabiliriz.
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

//ESP32 ismi tanımlanmaktadır.
#define ESP32NAME "SmartBreath"

/*int sicaklik_konum=14;

int sicaklik_deger;*/


//Bluetooth bağlantısının gerçekleştirilmesi veya bağlantı kesilme işlemleri tanımlanıyor.
class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("Ble Bağlanıldı...");
      BLEDevice::startAdvertising();
    };

    void onDisconnect(BLEServer* pServer) {
      Serial.println("Ble Bağlantısı Kesildi...");
      deviceConnected = false;
    }
};

//Sensörlerden alınan verilerin güncellemesi yapılmaktadır.
void updatetemp(float temp2){
  if(temp!=temp2){
    String tempString="";
    tempString+=(int)temp2;
    temp=temp2;
  }
}

void updatehumi(float humidity2){
  if(humidity!=humidity2){
    String humidityString="";
    humidityString+=(int)humidity2;
    humidity=humidity2;
  }
}

//ESP32'nin bluetooth modülü bluetooth düşük güç energy (Bluetooth Low Energy) için ayarlamalar gerçekleştiriliyor.
//Bluetooth Low Energy (BLE) yapılmasının sebebi IOS işletim sistemi kullanan mobil cihazların bluetoothu içindir.
void setup(void)
{
  Serial.begin(115200);
  Serial.println("Ble Başladı");

  dht.begin();
  pinMode(mq9pin, INPUT);

  //pinMode(sicaklik_konum,INPUT);

  // Create the BLE Device
  BLEDevice::init(ESP32NAME);

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE
                    );

  pCharacteristic->addDescriptor(new BLE2902());

  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising();
  Serial.println("Bluetooth Bağlantısı Bekleniyor...");
}

//Sensörlerden veriler alınmaktadır ve bağlı olan bluetootha gönderimi gerçekleştirilmektedir.
void loop(void){
  updatetemp(dht.readTemperature());
  updatehumi(dht.readHumidity());
  mq9value = analogRead(mq9pin);
  mq9voltage = mq9value/1024*5.0;
  if (deviceConnected) {
    /*sicaklik_deger=analogRead(sicaklik_konum);
    Serial.print("Sıcaklık ");
    Serial.print(sicaklik_deger);
    Serial.println("* C");
    char sicaklik[8];
    dtostrf(sicaklik_deger,1,2,sicaklik);
    pCharacteristic->setValue(sicaklik);
    pCharacteristic->notify();*/
    String sonuc="";
    sonuc+=temp;
    sonuc+=",";
    sonuc+=humidity;
    sonuc+=",";
    sonuc+=mq9voltage;
    Serial.print("Sıcaklık: ");
    Serial.print(temp);
    Serial.print(" C");
    Serial.print("\t");
    Serial.print("Humidity: ");
    Serial.print(" %");
    //Serial.print("\t");
    Serial.print("Gaz: ");
    Serial.print(mq9value);
    Serial.println();
    Serial.print("Gaz: ");
    Serial.print(mq9value);
    Serial.print("\t");
    Serial.print("Gaz Voltage: ");
    Serial.print(mq9voltage);
    Serial.println();
    

    pCharacteristic->setValue((char*)sonuc.c_str());
    pCharacteristic->notify();
    }
    
   if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
    }
    // connecting
   if (deviceConnected && !oldDeviceConnected) {
        // do stuff here on connecting
        oldDeviceConnected = deviceConnected;
   }
  
  delay(2000);
}

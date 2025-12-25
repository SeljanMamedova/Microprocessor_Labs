//Code For Master 

#include <Wire.h>                                   // I2C library

#define SLAVE_ADDR 0x08                  
#define BUTTON_PIN 2                              // push button pin (active LOW)
#define LED_PIN 8                       

void setup() {
  Wire.begin();                                  // initialize I2C as master

  pinMode(BUTTON_PIN, INPUT_PULLUP);           // configure button pin with pull-up
  pinMode(LED_PIN, OUTPUT);                    // configure LED pin as output
}

void loop() {
  uint8_t buttonState = (digitalRead(BUTTON_PIN) == LOW) ? 1 : 0;        // read button state

  Wire.beginTransmission(SLAVE_ADDR);                                   // start transmission to slave
  Wire.write(buttonState);                                             // send button state (1 byte)
  Wire.endTransmission();                                             // end transmission

  Wire.requestFrom(SLAVE_ADDR, 1);                                   // request 1 byte from slave

  if (Wire.available()) {                                           // check if slave sent data
    uint8_t received = Wire.read();                                // read received byte
    digitalWrite(LED_PIN, received ? HIGH : LOW);                 // control LED based on received data
  }

  delay(100);                                                  // small delay 
}


//Code For Slave

#include <Wire.h>                       

#define SLAVE_ADDR 0x08                  
#define BUTTON_PIN 2                    
#define LED_PIN 3

volatile uint8_t receivedData = 0;                            // store data received from master

void receiveEvent(int howMany) {                             // called when master sends data
  if (Wire.available()) {                                   // check if data is available
    receivedData = Wire.read();                            // read received byte
    digitalWrite(LED_PIN, receivedData ? HIGH : LOW);     // control LED
  }
}

void requestEvent() {                                  // called when master requests data
  uint8_t buttonState = (digitalRead(BUTTON_PIN) == LOW) ? 1 : 0; 
  Wire.write(buttonState);                            // send button state to master
}

void setup() {
  Wire.begin(SLAVE_ADDR);               

  Wire.onReceive(receiveEvent);                   // register receive handler
  Wire.onRequest(requestEvent);                  // register request handler

  pinMode(BUTTON_PIN, INPUT_PULLUP);            // configure button pin
  pinMode(LED_PIN, OUTPUT);                    // configure LED pin
}

void loop() {
  // nothing required here, communication handled by interrupts
}

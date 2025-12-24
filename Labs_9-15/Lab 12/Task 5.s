//Code For Master 

#include <Wire.h>

// I2C slave address (Board B)
#define SLAVE_ADDR 0x08

// Push button pin (active LOW)
#define BUTTON_PIN 2

// LED pin
#define LED_PIN 8

// ----------------------------------------------------
// Setup function (runs once)
// ----------------------------------------------------
void setup() {
  // Initialize I2C as MASTER (no address needed)
  Wire.begin();

  // Configure button pin as input with internal pull-up
  pinMode(BUTTON_PIN, INPUT_PULLUP);

  // Configure LED pin as output
  pinMode(LED_PIN, OUTPUT);
}

// ----------------------------------------------------
// Main loop
// ----------------------------------------------------
void loop() {
  // Read button state (LOW when pressed)
  // Convert to 1 when pressed, 0 when not pressed
  uint8_t buttonState = (digitalRead(BUTTON_PIN) == LOW) ? 1 : 0;

  // Send button state to SLAVE (Board B)
  Wire.beginTransmission(SLAVE_ADDR);
  Wire.write(buttonState);          // send one byte
  Wire.endTransmission();           // end transmission

  // Request one byte back from SLAVE
  Wire.requestFrom(SLAVE_ADDR, 1);

  // If data is available from slave
  if (Wire.available()) {
    uint8_t received = Wire.read(); // read received data

    // Control LED based on received value
    digitalWrite(LED_PIN, received ? HIGH : LOW);
  }

  // Small delay to slow down communication
  delay(100);
}


//Code For Slave

// I2C SLAVE – Arduino Uno

#include <Wire.h>

// I2C slave address
#define SLAVE_ADDR 0x08

// Button pin (active LOW)
#define BUTTON_PIN 2

// LED pin
#define LED_PIN 3

// Variable to store data received from MASTER
volatile uint8_t receivedData = 0;

// ----------------------------------------------------
// Called automatically when MASTER sends data
// ----------------------------------------------------
void receiveEvent(int howMany) {
  // Check if data is available from master
  if (Wire.available()) {
    receivedData = Wire.read();          // read received byte

    // Control LED based on received value
    digitalWrite(LED_PIN, receivedData ? HIGH : LOW);
  }
}

// ----------------------------------------------------
// Called automatically when MASTER requests data
// ----------------------------------------------------
void requestEvent() {
  // Read button state (LOW when pressed)
  // Convert to 1 when pressed, 0 when not pressed
  uint8_t buttonState = (digitalRead(BUTTON_PIN) == LOW) ? 1 : 0;

  // Send button state back to MASTER
  Wire.write(buttonState);
}

// ----------------------------------------------------
// Setup function (runs once)
// ----------------------------------------------------
void setup() {
  // Initialize I2C as SLAVE with address 0x08
  Wire.begin(SLAVE_ADDR);

  // Register receive and request interrupt handlers
  Wire.onReceive(receiveEvent);
  Wire.onRequest(requestEvent);

  // Configure button pin as input with internal pull-up
  pinMode(BUTTON_PIN, INPUT_PULLUP);

  // Configure LED pin as output
  pinMode(LED_PIN, OUTPUT);
}

// ----------------------------------------------------
// Main loop
// ----------------------------------------------------
void loop() {
  // Nothing needed here
  // I2C communication handled by interrupts
}


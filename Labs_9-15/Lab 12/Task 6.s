// I2C MASTER – Arduino Uno

#include <Wire.h>

// I2C slave address
#define SLAVE_ADDR 0x08

// Number of messages to send
#define NUM_MESSAGES 50

// ----------------------------------------------------
// Setup function (runs once)
// ----------------------------------------------------
void setup() {
  // Initialize serial communication
  Serial.begin(9600);

  // ---- SET I2C SPEED HERE ----

  // Set TWI prescaler to 1 (TWPS1=0, TWPS0=0)
  TWSR &= ~((1 << TWPS0) | (1 << TWPS1));

  // Choose ONE I2C clock speed by setting TWBR
  // TWBR = 312;   // ~25 kHz I2C clock
  // TWBR = 72;    // ~100 kHz I2C clock
  // TWBR = 12;    // ~400 kHz I2C clock

  // Initialize I2C as MASTER
  Wire.begin();
}

// ----------------------------------------------------
// Main loop
// ----------------------------------------------------
void loop() {
  // Record start time
  unsigned long startTime = millis();

  // Send and receive NUM_MESSAGES times
  for (int i = 0; i < NUM_MESSAGES; i++) {

    // Send one byte to SLAVE
    Wire.beginTransmission(SLAVE_ADDR);
    Wire.write(1);                // send dummy data
    Wire.endTransmission();       // end transmission

    // Request one byte from SLAVE
    Wire.requestFrom(SLAVE_ADDR, 1);

    // Read received byte (if available)
    while (Wire.available()) {
      Wire.read();
    }
  }

  // Record end time
  unsigned long endTime = millis();

  // Print total time for sending 50 messages
  Serial.print("Time for 50 messages: ");
  Serial.print(endTime - startTime);
  Serial.println(" ms");

  // Wait before repeating measurement
  delay(3000);
}


//Code for Slave


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

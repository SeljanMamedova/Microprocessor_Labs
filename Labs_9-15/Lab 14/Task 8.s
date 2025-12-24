//Code For Master 

// Secret key used for XOR encryption
#define SECRET_KEY 0x5A

// Counter value to be encrypted and sent
uint8_t counter = 0;

// ----------------------------------------------------
// Simple XOR encryption function
// ----------------------------------------------------
uint8_t encrypt(uint8_t plain) {
  // XOR plaintext with secret key
  return plain ^ SECRET_KEY;
}

// ----------------------------------------------------
// Setup function (runs once)
// ----------------------------------------------------
void setup() {
  // Initialize UART serial communication
  Serial.begin(9600);
}

// ----------------------------------------------------
// Main loop
// ----------------------------------------------------
void loop() {
  // Use counter value as plaintext
  uint8_t plaintext = counter;

  // Encrypt plaintext
  uint8_t ciphertext = encrypt(plaintext);

  // Send encrypted byte over UART
  Serial.write(ciphertext);

  // Increment counter for next transmission
  counter++;

  // Small delay between transmissions (0.1 seconds)
  delay(100);
}




//Code For Slave

// Secret key used for XOR decryption
#define SECRET_KEY 0x5A

// ----------------------------------------------------
// Simple XOR decryption function
// ----------------------------------------------------
uint8_t decrypt(uint8_t cipher) {
  // XOR ciphertext with secret key
  // (same operation as encryption)
  return cipher ^ SECRET_KEY;
}

// ----------------------------------------------------
// Setup function (runs once)
// ----------------------------------------------------
void setup() {
  // Initialize UART serial communication for receiving data
  Serial.begin(9600);
}

// ----------------------------------------------------
// Main loop
// ----------------------------------------------------
void loop() {
  // Check if data is available on serial buffer
  if (Serial.available() > 0) {
    // Read encrypted byte from UART
    uint8_t cipher = Serial.read();

    // Decrypt received data
    uint8_t plain = decrypt(cipher);

    // Print decrypted value to Serial Monitor
    Serial.print("Decrypted value: ");
    Serial.println(plain);
  }
}


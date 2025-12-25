//Code For Master 

#define SECRET_KEY 0x5A                  

uint8_t counter = 0;                    // counter value to be encrypted and sent

uint8_t encrypt(uint8_t plain) {        // simple XOR encryption function
  return plain ^ SECRET_KEY;            // encrypt plaintext using XOR
}

void setup() {
  Serial.begin(9600);                   // initialize UART serial communication
}

void loop() {
  uint8_t plaintext = counter;          // use counter as plaintext data

  uint8_t ciphertext = encrypt(plaintext);              // encrypt plaintext

  Serial.write(ciphertext);                          // send encrypted byte over UART

  counter++;                                            // increment counter for next send

  delay(100);                                             // delay 0.1 seconds 
}




//Code For Slave

#define SECRET_KEY 0x5A                 // secret key for XOR decryption

uint8_t decrypt(uint8_t cipher) {       // simple XOR decryption function
  return cipher ^ SECRET_KEY;          
}

void setup() {
  Serial.begin(9600);                   
}

void loop() {
  if (Serial.available() > 0) {                           // check if data is available
    uint8_t cipher = Serial.read();                      // read encrypted byte from UART

    uint8_t plain = decrypt(cipher);                    // decrypt received data

    Serial.print("Decrypted value: ");                     // print label
    Serial.println(plain);                                 // print decrypted value
  }
}

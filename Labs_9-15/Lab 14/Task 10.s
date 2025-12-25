#include <stdint.h>                     

const uint8_t cipher[] = {
  87, 26, 72, 13, 67,
  95, 89, 23, 72, 22,
  73, 11, 87, 30, 73
};
const uint8_t cipherLen = sizeof(cipher);                      // length of cipher array

char plaintext[cipherLen + 1];                                 // buffer for decrypted plaintext 

bool isTwoLowercaseWords(const char *s) {                     // check if plaintext is two lowercase words
  int spaces = 0;                                             // counter for spaces

  for (uint8_t i = 0; i < cipherLen; i++) {                   // loop through characters
    char c = s[i];                                           // current character

    if (c == ' ') {                                            // check for space
      spaces++;                                               // count spaces
    }
    else if (c < 'a' || c > 'z') {                      // check if not lowercase letter
      return false;                                  // if invalid character found
    }
  }

  if (spaces != 1) return false;                              // must contain exactly one space
  if (s[0] == ' ' || s[cipherLen - 1] == ' ') return false;        // no trailing space

  return true;                                                    // valid two-word lowercase string
}

void setup() {
  Serial.begin(9600);                    
  while (!Serial) { ; }                                            // wait for serial connection

  Serial.println(F("Starting brute-force of two XOR keys...\n"));        // start message

  unsigned long startTotal = millis();                               // record total start time

  for (uint16_t key0 = 0; key0 < 256; key0++) {                         // loop through first key
    for (uint16_t key1 = 0; key1 < 256; key1++) {                         // loop through second key

      for (uint8_t i = 0; i < cipherLen; i++) {                               // decrypt each byte
        uint8_t useKey = (i & 1) ? key1 : key0;                            // alternate keys by index
        plaintext[i] = (char)(cipher[i] ^ useKey);     
      }
      plaintext[cipherLen] = '\0';                                             // null-terminate string

      if (isTwoLowercaseWords(plaintext)) {                                   // check if plaintext looks valid
        unsigned long elapsed = millis() - startTotal;                       // time until match found

        Serial.println(F("POSSIBLE MATCH FOUND"));                              // print match message
        Serial.print(F("key0 = "));
        Serial.print(key0);                           
        Serial.print(F(" (0x"));
        Serial.print(key0, HEX);                                               // print key0 in hex
        Serial.println(F(")"));

        Serial.print(F("key1 = "));
        Serial.print(key1);                                                       // print key1 value
        Serial.print(F(" (0x"));
        Serial.print(key1, HEX);                       
        Serial.println(F(")"));

        Serial.print(F("Plaintext: \""));
        Serial.print(plaintext);                                              // print decrypted text
        Serial.println(F("\""));

        Serial.print(F("Time taken until match (ms): "));
        Serial.println(elapsed);                                             // print elapsed time
        Serial.println(F("\n"));
      }
    }
  }

  unsigned long totalElapsed = millis() - startTotal;                          // total execution time

  Serial.println(F("finished."));                                   // completion message
  Serial.print(F("EXECUTION TIME (ms): "));
  Serial.println(totalElapsed);                                                      // print total time
}

void loop() {
  // nothing here, program runs once in setup
}

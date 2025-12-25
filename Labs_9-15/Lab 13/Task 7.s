#include <Arduino.h>                    

#define PRIME_TARGET 2000                     // number of prime numbers to find

uint8_t isPrime(uint16_t n) {             // function to check if number is prime
  if (n < 2) return 0;                    // numbers less than 2 are not prime

  if (n == 2) return 1;                   

  if ((n & 1) == 0) return 0;             

  for (uint16_t d = 3; (uint32_t)d * d <= n; d += 2) {             // test odd divisors up to sqrt(n)
    if (n % d == 0)
      return 0;                                                    // divisible, not prime
  }

  return 1;                                                    // number is prime
}

void setup() {
  DDRB |= (1 << PB5);                                 // set PB5 (onboard LED) as output

  uint16_t count = 0;                               // counter for primes found
  uint16_t n = 2;                                    // starting number to test

  unsigned long startTime = micros();                 // record start time in microseconds

  while (count < PRIME_TARGET) {                      // loop until required primes are found
    if (isPrime(n)) {                                   // check if current number is prime
      PORTB ^= (1 << PB5);                                // toggle LED for each prime found
      count++;                                         // increment prime counter
    }
    n++;                                  // check next number
  }

  unsigned long endTime = micros();                // record end time

  unsigned long elapsed = endTime - startTime;          // calculate execution time

  volatile unsigned long executionTime = elapsed; 

  while (1) {}                                              // stop program after computation
}

void loop() {

}

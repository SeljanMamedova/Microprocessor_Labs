#include <Arduino.h>

// Number of prime numbers to find
#define PRIME_TARGET 2000

// ----------------------------------------------------
// Function to check if a number is prime
// Returns 1 if prime, 0 if not prime
// ----------------------------------------------------
uint8_t isPrime(uint16_t n) {
  // Numbers less than 2 are not prime
  if (n < 2) return 0;

  // 2 is the only even prime
  if (n == 2) return 1;

  // Even numbers greater than 2 are not prime
  if ((n & 1) == 0) return 0;

  // Check odd divisors up to sqrt(n)
  for (uint16_t d = 3; (uint32_t)d * d <= n; d += 2) {
    if (n % d == 0)
      return 0;   // not prime
  }

  // Number is prime
  return 1;
}

// ----------------------------------------------------
// Setup function (runs once)
// ----------------------------------------------------
void setup() {
  // Set PB5 (onboard LED) as OUTPUT
  DDRB |= (1 << PB5);

  uint16_t count = 0;   // number of primes found
  uint16_t n = 2;       // number to test for primality

  // Start high-resolution timing (microseconds)
  unsigned long startTime = micros();

  // Find PRIME_TARGET number of primes
  while (count < PRIME_TARGET) {
    if (isPrime(n)) {
      PORTB ^= (1 << PB5);   // toggle LED for each prime found
      count++;               // increment prime counter
    }
    n++;                     // move to next number
  }

  // Stop timing
  unsigned long endTime = micros();

  // Calculate total execution time
  unsigned long elapsed = endTime - startTime;

  // Store execution time (useful for debugging)
  volatile unsigned long executionTime = elapsed;

  // Stop program after computation finishes
  while (1) {}
}

// ----------------------------------------------------
// Main loop (not used)
// ----------------------------------------------------
void loop() {
  // nothing here
}
